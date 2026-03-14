enum InkRole { artist, owner, client }

extension InkRoleX on InkRole {
  String get label {
    switch (this) {
      case InkRole.artist:
        return 'Artist';
      case InkRole.owner:
        return 'Owner';
      case InkRole.client:
        return 'Client';
    }
  }
}
