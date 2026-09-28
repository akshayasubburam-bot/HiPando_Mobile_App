import { Router } from 'express';
import {
  getProperties,
  getFeaturedProperties,
  getPropertyById,
} from '../controllers/propertyController.js';

const router = Router();

// IMPORTANT: /featured must be registered BEFORE /:id
// otherwise Express will treat "featured" as an ID parameter.
router.get('/featured', getFeaturedProperties);
router.get('/',         getProperties);
router.get('/:id',      getPropertyById);

export default router;
