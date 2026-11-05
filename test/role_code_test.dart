import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/app/role_code.dart';
import 'package:safety_observation/app/user_role.dart';

void main() {
  test('generated codes decode to their assigned role', () {
    final employeeCode = RoleCode.generate(UserRole.employee);
    final supervisorCode = RoleCode.generate(UserRole.supervisor);

    expect(RoleCode.decode(employeeCode), UserRole.employee);
    expect(RoleCode.decode(supervisorCode), UserRole.supervisor);
  });

  test('invalid or edited codes are rejected', () {
    final code = RoleCode.generate(UserRole.supervisor);

    expect(RoleCode.decode('not a code'), isNull);
    expect(RoleCode.decode('${code.substring(0, code.length - 1)}0'), isNull);
  });
}
