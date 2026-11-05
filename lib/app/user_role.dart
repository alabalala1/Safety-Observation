enum UserRole { employee, supervisor }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.employee => 'Employee',
        UserRole.supervisor => 'Supervisor',
      };
}
