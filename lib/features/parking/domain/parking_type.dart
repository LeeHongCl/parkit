enum ParkingType {
  public,
  private;

  String get label {
    switch (this) {
      case ParkingType.public:
        return '공영';
      case ParkingType.private:
        return '민영';
    }
  }
}
