class FareService {
  constructor() {
    this.baseFares = {
      'Ride': 50,
      'Mini': 40,
      'Lux': 100,
      'Package': 60,
      'Intercity': 200,
      'Rentals': 150
    };
    this.ratesPerKm = {
      'Ride': 25,
      'Mini': 20,
      'Lux': 50,
      'Package': 30,
      'Intercity': 40,
      'Rentals': 45
    };
  }

  calculateFare(distanceInMeters, category = 'Ride') {
    const distanceInKm = distanceInMeters / 1000;
    const base = this.baseFares[category] || this.baseFares['Ride'];
    const rate = this.ratesPerKm[category] || this.ratesPerKm['Ride'];
    
    const totalFare = base + (distanceInKm * rate);
    return Math.round(totalFare);
  }
}

module.exports = new FareService();
