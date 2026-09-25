class FaqEntry {
  final List<String> keywords;
  final String answer;
  const FaqEntry(this.keywords, this.answer);
}

final List<FaqEntry> botFaq = [
  FaqEntry(
    ['brokerage', 'commission', 'fee'],
    'Brokerage commission in Dubai is typically 2% of the sale price, paid by the buyer, plus 5% VAT on the commission.',
  ),
  FaqEntry(
    ['document', 'documents', 'paperwork'],
    'You will need a passport copy, Emirates ID (if a resident), and proof of funds. I can prepare the checklist for your specific deal.',
  ),
  FaqEntry(
    ['freehold', 'leasehold'],
    'Freehold areas allow full foreign ownership of the property and land. Leasehold gives long-term usage rights, usually up to 99 years, without owning the land.',
  ),
  FaqEntry(
    ['foreigner', 'foreign', 'non-uae', 'expat', 'ownership'],
    'Foreigners can buy freehold property in designated areas such as Downtown Dubai, Palm Jumeirah, Dubai Marina, and Business Bay.',
  ),
  FaqEntry(
    ['visit', 'viewing', 'tour'],
    'I can schedule a private site visit with one of our agents at a time that suits you — just tell me your preferred day.',
  ),
  FaqEntry(
    ['negotiate', 'negotiation', 'lower price', 'discount'],
    'Negotiation is common in Dubai, especially on secondary market resales. I can share comparable sales to support your offer.',
  ),
];

String? matchFaq(String message) {
  final lower = message.toLowerCase();
  for (final entry in botFaq) {
    if (entry.keywords.any((k) => lower.contains(k))) return entry.answer;
  }
  return null;
}
