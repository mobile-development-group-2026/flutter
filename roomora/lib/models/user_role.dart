enum UserRole {
  student('Student', '🎓'),
  landlord('Landlord', '🏠');

  final String label;
  final String icon;

  const UserRole(this.label, this.icon);

  String get value => name; 
}