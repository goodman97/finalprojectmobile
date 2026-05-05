// Available Timezones for User Preferences
// Used in: /api/auth/profile (PUT) with timezone field
// Default: 'Asia/Jakarta'

module.exports = {
  // Asia
  'Asia/Jakarta': 'Indonesia (UTC+7)',
  'Asia/Bangkok': 'Thailand (UTC+7)',
  'Asia/Manila': 'Philippines (UTC+8)',
  'Asia/Singapore': 'Singapore (UTC+8)',
  'Asia/Hong_Kong': 'Hong Kong (UTC+8)',
  'Asia/Shanghai': 'China (UTC+8)',
  'Asia/Tokyo': 'Japan (UTC+9)',
  'Asia/Seoul': 'South Korea (UTC+9)',
  'Asia/Dubai': 'UAE (UTC+4)',
  'Asia/Kolkata': 'India (UTC+5:30)',
  'Asia/Bangkok': 'Thailand (UTC+7)',
  
  // Europe
  'Europe/London': 'UK (UTC+0/+1)',
  'Europe/Paris': 'France (UTC+1/+2)',
  'Europe/Berlin': 'Germany (UTC+1/+2)',
  'Europe/Amsterdam': 'Netherlands (UTC+1/+2)',
  'Europe/Moscow': 'Russia (UTC+3)',
  
  // Americas
  'America/New_York': 'USA Eastern (UTC-5/-4)',
  'America/Chicago': 'USA Central (UTC-6/-5)',
  'America/Denver': 'USA Mountain (UTC-7/-6)',
  'America/Los_Angeles': 'USA Pacific (UTC-8/-7)',
  'America/Anchorage': 'USA Alaska (UTC-9/-8)',
  'America/Toronto': 'Canada Eastern (UTC-5/-4)',
  'America/Vancouver': 'Canada Pacific (UTC-8/-7)',
  'America/Mexico_City': 'Mexico (UTC-6/-5)',
  'America/Sao_Paulo': 'Brazil (UTC-3/-2)',
  
  // Africa
  'Africa/Cairo': 'Egypt (UTC+2)',
  'Africa/Johannesburg': 'South Africa (UTC+2)',
  'Africa/Lagos': 'Nigeria (UTC+1)',
  
  // Oceania
  'Australia/Sydney': 'Australia Eastern (UTC+10/+11)',
  'Australia/Melbourne': 'Australia Victoria (UTC+10/+11)',
  'Australia/Brisbane': 'Australia Queensland (UTC+10)',
  'Australia/Perth': 'Australia Western (UTC+8)',
  'Pacific/Auckland': 'New Zealand (UTC+12/+13)',
  'Pacific/Fiji': 'Fiji (UTC+12/+13)',
  
  // UTC
  'UTC': 'Universal Time Coordinated'
};
