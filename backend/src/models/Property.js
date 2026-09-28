import mongoose from 'mongoose';

/**
 * Mongoose schema mapped to the real `listings` collection in Pando_ai.
 *
 * Actual document structure (confirmed from DB inspection):
 * {
 *   _id: ObjectId,
 *   originalId: "prop-1",
 *   title: "Palm Jumeirah Beachfront Sanctuary",
 *   description: "...",
 *   purpose: "sale",          // "sale" | "rent" | "off-plan"
 *   propertyType: "Beachfront Villa",
 *   category: "Villas",      // "Villas" | "Apartments" | "Townhouses" | "Penthouses" | "Off-Plan"
 *   source: "developer",
 *   listedBy: "Emaar Properties",
 *   price: 85000000,          // AED
 *   bedrooms: 6,
 *   bathrooms: 7,
 *   areaSqft: 8400,
 *   furnishing: "Furnished",
 *   community: "Palm Jumeirah",
 *   city: "Dubai",
 *   coordinates: { lat: 25.1034, lng: 55.13 },
 *   images: ["url1", "url2", "url3"],
 *   amenities: ["Private Mooring", "Pool", ...],
 *   aiScore: 92.05,
 *   yield: 4.42,
 *   createdAt: Date
 * }
 */
const listingSchema = new mongoose.Schema(
  {
    originalId:   { type: String },
    title:        { type: String, required: true },
    description:  { type: String, default: '' },
    purpose:      { type: String, default: 'sale' },   // sale | rent | off-plan
    propertyType: { type: String, default: '' },
    category:     { type: String, default: '' },
    source:       { type: String, default: '' },
    listedBy:     { type: String, default: '' },
    price:        { type: Number, required: true },
    bedrooms:     { type: Number, default: 0 },
    bathrooms:    { type: Number, default: 0 },
    areaSqft:     { type: Number, default: 0 },
    furnishing:   { type: String, default: 'Unfurnished' },
    community:    { type: String, default: '' },
    city:         { type: String, default: 'Dubai' },
    coordinates: {
      lat: { type: Number, default: 25.2048 },
      lng: { type: Number, default: 55.2708 },
    },
    images:    { type: [String], default: [] },
    amenities: { type: [String], default: [] },
    aiScore:   { type: Number, default: 0 },
    yield:     { type: Number, default: 0 },
  },
  {
    // Map to the existing `listings` collection — do NOT create a new one
    collection: 'listings',
    timestamps: { createdAt: 'createdAt', updatedAt: false },
  }
);

// Indexes for common query patterns
listingSchema.index({ purpose: 1 });
listingSchema.index({ community: 1 });
listingSchema.index({ price: 1 });
listingSchema.index({ aiScore: -1 });

const Listing = mongoose.model('Listing', listingSchema);

export default Listing;
