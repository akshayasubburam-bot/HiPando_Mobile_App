import mongoose from 'mongoose';
import Listing from '../models/Property.js';

const MAX_LIMIT = 50;

// ─── Helpers ────────────────────────────────────────────────────────────────

/**
 * Validates a MongoDB ObjectId string.  Returns true if valid.
 */
function isValidObjectId(id) {
  return mongoose.Types.ObjectId.isValid(id);
}

/**
 * Shapes a raw Mongoose document into the response object Flutter expects.
 * Maps real DB field names → Flutter Property model fields.
 */
function shapeProperty(doc) {
  const d = doc.toObject ? doc.toObject() : doc;
  return {
    id:            d._id.toString(),
    title:         d.title         || '',
    community:     d.community     || '',
    type:          d.propertyType  || '',
    purpose:       (d.purpose || 'sale').toLowerCase(),   // 'sale' | 'rent' | 'off-plan'
    category:      (d.category || '').toLowerCase(),      // 'villas' | 'apartments' | ...
    price:         typeof d.price === 'number' ? Math.round(d.price) : 0,
    priceUsd:      typeof d.price === 'number' ? Math.round(d.price / 3.67) : 0,
    bedrooms:      d.bedrooms  || 0,
    bathrooms:     d.bathrooms || 0,
    areaSqft:      d.areaSqft  || 0,
    furnishing:    d.furnishing || 'Unfurnished',
    images:        Array.isArray(d.images) && d.images.length > 0
                     ? d.images
                     : ['https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200'],
    amenities:     Array.isArray(d.amenities) ? d.amenities : [],
    tags:          buildTags(d),
    description:   d.description   || '',
    locationLine:  buildLocationLine(d),
    lat:           d.coordinates?.lat ?? 25.2048,
    lng:           d.coordinates?.lng ?? 55.2708,
    indexLabel:    d.aiScore ? `SCORE: ${d.aiScore.toFixed(1)}` : '',
    verified:      true,
    ribbon:        buildRibbon(d),
    highlight:     d.description ? d.description.slice(0, 120) : '',
    standoutReason: buildStandoutReason(d),
    listedBy:      d.listedBy || '',
    rentalYield:   d.yield    || 0,
  };
}

function buildLocationLine(d) {
  const city = d.city || 'Dubai';
  const community = d.community || '';
  const type = d.propertyType || '';
  if (community && type) return `${community}, ${city} • ${type}`;
  if (community) return `${community}, ${city}`;
  return city;
}

function buildTags(d) {
  const tags = [];
  if (d.purpose === 'rent') tags.push('For Rent');
  if (d.purpose === 'off-plan') tags.push('Off-Plan');
  if (d.community) tags.push(d.community);
  if (d.propertyType) tags.push(d.propertyType);
  return tags.slice(0, 4);
}

function buildRibbon(d) {
  if (d.aiScore >= 90) return 'Top Rated';
  if (d.purpose === 'off-plan') return 'Off-Plan';
  return '';
}

function buildStandoutReason(d) {
  const parts = [];
  if (d.community) parts.push(`prime ${d.community} location`);
  if (d.yield && d.yield > 0) parts.push(`${d.yield.toFixed(1)}% rental yield`);
  if (d.furnishing && d.furnishing !== 'Unfurnished') parts.push(d.furnishing.toLowerCase());
  return parts.length > 0 ? parts.join(', ') : 'quality and location';
}

// ─── Controllers ────────────────────────────────────────────────────────────

/**
 * GET /api/v1/properties
 * Returns a paginated list of all properties from the listings collection.
 */
export async function getProperties(req, res) {
  try {
    const page  = Math.max(1, parseInt(req.query.page)  || 1);
    const limit = Math.min(MAX_LIMIT, Math.max(1, parseInt(req.query.limit) || 20));
    const skip  = (page - 1) * limit;

    // Optional filter by purpose
    const filter = {};
    if (req.query.purpose) {
      filter.purpose = req.query.purpose.toLowerCase();
    }

    const [docs, total] = await Promise.all([
      Listing.find(filter).sort({ aiScore: -1 }).skip(skip).limit(limit).lean(),
      Listing.countDocuments(filter),
    ]);

    const totalPages = Math.ceil(total / limit);

    return res.status(200).json({
      success: true,
      message: 'Properties retrieved successfully',
      data: docs.map(d => shapeProperty({ toObject: () => d, ...d })),
      pagination: { page, limit, total, totalPages },
    });
  } catch (err) {
    console.error('[getProperties] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve properties',
    });
  }
}

/**
 * GET /api/v1/properties/featured
 * Returns up to 10 top-rated properties (highest aiScore).
 */
export async function getFeaturedProperties(req, res) {
  try {
    const docs = await Listing.find({}).sort({ aiScore: -1 }).limit(10).lean();

    return res.status(200).json({
      success: true,
      message: 'Featured properties retrieved successfully',
      data: docs.map(d => shapeProperty({ toObject: () => d, ...d })),
    });
  } catch (err) {
    console.error('[getFeaturedProperties] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve featured properties',
    });
  }
}

/**
 * GET /api/v1/properties/:id
 * Returns a single property by its MongoDB _id.
 */
export async function getPropertyById(req, res) {
  const { id } = req.params;

  if (!isValidObjectId(id)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid property ID format',
    });
  }

  try {
    const doc = await Listing.findById(id).lean();

    if (!doc) {
      return res.status(404).json({
        success: false,
        message: `Property with ID "${id}" was not found`,
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Property retrieved successfully',
      data: shapeProperty({ toObject: () => doc, ...doc }),
    });
  } catch (err) {
    console.error('[getPropertyById] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve property',
    });
  }
}
