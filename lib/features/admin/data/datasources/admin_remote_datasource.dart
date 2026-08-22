import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/audit_entry_model.dart';
import '../models/cabinet_settings_model.dart';
import '../models/cabinet_user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<CabinetUserModel>> getUsers({
    String? search,
    String? role,
    bool? isActive,
  });

  Future<CabinetUserModel> getUserById(int id);

  Future<CabinetUserModel> createUser(Map<String, dynamic> data);

  Future<CabinetUserModel> updateUser(int id, Map<String, dynamic> data);

  Future<CabinetUserModel> toggleUserStatus(int id, bool isActive);

  Future<List<AuditEntryModel>> getAuditTrail({
    String? search,
    String? action,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<CabinetSettingsModel> getCabinetSettings();

  Future<CabinetSettingsModel> updateCabinetSettings(Map<String, dynamic> data);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioClient dioClient;

  // In-memory cache for session-created entities
  static final List<CabinetUserModel> _dynamicUsers = [];
  static final List<AuditEntryModel> _sessionAuditLogs = [];

  static CabinetSettingsModel _cabinetSettings = const CabinetSettingsModel(
    id: 1,
    cabinetName: 'Cabinet Dentaire Central',
    cabinetCode: 'CAB-PARIS-01',
    address: '14 Boulevard Saint-Germain, 75005 Paris',
    phone: '+33 1 42 68 00 00',
    email: 'contact@cabinet-central.fr',
    dlcThresholdDays: 30,
    lowStockThreshold: 5,
    enableBiometrics: true,
    autoSyncEnabled: true,
    primaryAutoclaveId: 'MELAG-VACUKLAV-40B',
  );

  AdminRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<CabinetUserModel>> getUsers({
    String? search,
    String? role,
    bool? isActive,
  }) async {
    final List<CabinetUserModel> usersList = [];

    // 1. Fetch from backend API /users
    try {
      final qParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) qParams['search'] = search;
      if (role != null && role.isNotEmpty && role != 'all') qParams['role'] = role;
      if (isActive != null) qParams['is_active'] = isActive ? 1 : 0;

      final response = await dioClient.get(
        '/users',
        queryParameters: qParams.isNotEmpty ? qParams : null,
      );

      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is Map && data.containsKey('users') && data['users'] is List) {
        list = data['users'] as List;
      }

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final u = CabinetUserModel.fromJson(item);
          if (!usersList.any((existing) => existing.id == u.id)) {
            usersList.add(u);
          }
        }
      }
    } catch (_) {}

    // 2. Discover practitioners from live /usages if /users is empty or restricted
    if (usersList.isEmpty) {
      try {
        final usagesRes = await dioClient.get(ApiConstants.usages);
        final dynamic uData = usagesRes.data;
        List<dynamic> uList = [];
        if (uData is List) {
          uList = uData;
        } else if (uData is Map && uData['data'] is List) {
          uList = uData['data'] as List;
        }

        for (final item in uList) {
          if (item is Map<String, dynamic>) {
            final pName = item['practitioner_name'] as String? ?? item['user_name'] as String?;
            final pIdStr = item['practitioner_id']?.toString() ?? item['user_id']?.toString();
            final pId = int.tryParse(pIdStr ?? '') ?? 100;
            if (pName != null && pName.isNotEmpty) {
              if (!usersList.any((u) => u.name.toLowerCase() == pName.toLowerCase() || u.id == pId)) {
                usersList.add(
                  CabinetUserModel(
                    id: pId,
                    name: pName,
                    email: '${pName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '.')}@cabinet.fr',
                    role: 'practitioner',
                    isActive: true,
                    cabinetName: _cabinetSettings.cabinetName,
                    cabinetRoom: 'Fauteuil Clinique',
                    createdAt: DateTime.now().subtract(const Duration(days: 30)),
                    lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
                    permissions: const ['scan_labels', 'record_usage'],
                  ),
                );
              }
            }
          }
        }
      } catch (_) {}
    }

    // 3. Include any session created users
    for (final dynamicUser in _dynamicUsers) {
      if (!usersList.any((u) => u.id == dynamicUser.id || u.email.toLowerCase() == dynamicUser.email.toLowerCase())) {
        usersList.add(dynamicUser);
      }
    }

    return _filterUsers(usersList, search, role, isActive);
  }

  List<CabinetUserModel> _filterUsers(List<CabinetUserModel> users, String? search, String? role, bool? isActive) {
    return users.where((u) {
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final match = u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            (u.phone?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (role != null && role.isNotEmpty && role != 'all') {
        if (u.role.toLowerCase() != role.toLowerCase()) return false;
      }
      if (isActive != null) {
        if (u.isActive != isActive) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<CabinetUserModel> getUserById(int id) async {
    try {
      final response = await dioClient.get('/users/$id');
      final dynamic data = response.data;
      final map = (data is Map && data.containsKey('data')) ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
      return CabinetUserModel.fromJson(map);
    } catch (_) {
      final found = _dynamicUsers.where((u) => u.id == id).firstOrNull;
      if (found != null) return found;
      throw ServerException(message: 'User with ID $id not found.');
    }
  }

  @override
  Future<CabinetUserModel> createUser(Map<String, dynamic> data) async {
    CabinetUserModel? createdUser;
    final payload = {
      'name': data['name'],
      'email': data['email'],
      'phone': data['phone'],
      'cabinet_code': data['cabinet_code'] ?? _cabinetSettings.cabinetCode,
      'password': data['password'] ?? 'Password123!',
      'password_confirmation': data['password'] ?? 'Password123!',
      'role': data['role'] ?? 'practitioner',
      if (data['cabinet_room'] != null) 'cabinet_room': data['cabinet_room'],
    };

    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: payload,
      );

      final dynamic resData = response.data;
      Map<String, dynamic>? userMap;
      if (resData is Map && resData.containsKey('user')) {
        userMap = resData['user'] as Map<String, dynamic>;
      } else if (resData is Map && resData.containsKey('data')) {
        userMap = resData['data'] as Map<String, dynamic>;
      } else if (resData is Map) {
        userMap = resData as Map<String, dynamic>;
      }

      if (userMap != null) {
        createdUser = CabinetUserModel.fromJson(userMap);
      }
    } catch (_) {
      try {
        final response = await dioClient.post('/users', data: payload);
        final dynamic resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          createdUser = CabinetUserModel.fromJson(resData['data'] as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    if (createdUser == null) {
      final newId = DateTime.now().millisecondsSinceEpoch % 10000;
      createdUser = CabinetUserModel(
        id: newId,
        name: data['name'] as String? ?? 'New Staff Member',
        email: data['email'] as String? ?? 'user@cabinet.fr',
        phone: data['phone'] as String?,
        role: data['role'] as String? ?? 'practitioner',
        isActive: true,
        cabinetName: _cabinetSettings.cabinetName,
        cabinetRoom: data['cabinet_room'] as String? ?? 'Fauteuil #1',
        createdAt: DateTime.now(),
        lastLoginAt: null,
        permissions: (data['permissions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
    }

    _dynamicUsers.insert(0, createdUser);
    _logAudit(
      action: 'CREATE_USER',
      entityType: 'user',
      entityId: 'USR-${createdUser.id}',
      details: 'Created account for ${createdUser.name} with role ${createdUser.role.toUpperCase()}',
    );

    return createdUser;
  }

  @override
  Future<CabinetUserModel> updateUser(int id, Map<String, dynamic> data) async {
    CabinetUserModel? updatedUser;

    try {
      final response = await dioClient.put('/users/$id', data: data);
      final dynamic resData = response.data;
      final map = (resData is Map && resData.containsKey('data'))
          ? resData['data'] as Map<String, dynamic>
          : resData as Map<String, dynamic>;
      updatedUser = CabinetUserModel.fromJson(map);
    } catch (_) {
      try {
        final response = await dioClient.post('/users/$id', data: data);
        final dynamic resData = response.data;
        final map = (resData is Map && resData.containsKey('data'))
            ? resData['data'] as Map<String, dynamic>
            : resData as Map<String, dynamic>;
        updatedUser = CabinetUserModel.fromJson(map);
      } catch (_) {}
    }

    final index = _dynamicUsers.indexWhere((u) => u.id == id);
    if (index != -1) {
      final current = _dynamicUsers[index];
      updatedUser = CabinetUserModel(
        id: current.id,
        name: data['name'] as String? ?? current.name,
        email: data['email'] as String? ?? current.email,
        phone: data['phone'] as String? ?? current.phone,
        role: data['role'] as String? ?? current.role,
        isActive: data['is_active'] is bool ? data['is_active'] as bool : current.isActive,
        cabinetName: current.cabinetName,
        cabinetRoom: data['cabinet_room'] as String? ?? current.cabinetRoom,
        avatarUrl: current.avatarUrl,
        lastLoginAt: current.lastLoginAt,
        createdAt: current.createdAt,
        permissions: (data['permissions'] as List?)?.map((e) => e.toString()).toList() ?? current.permissions,
      );
      _dynamicUsers[index] = updatedUser;
    } else if (updatedUser != null) {
      _dynamicUsers.add(updatedUser);
    }

    if (updatedUser != null) {
      _logAudit(
        action: 'UPDATE_USER',
        entityType: 'user',
        entityId: 'USR-$id',
        details: 'Updated profile for ${updatedUser.name} (${updatedUser.role})',
      );
      return updatedUser;
    }

    throw ServerException(message: 'User not found: $id');
  }

  @override
  Future<CabinetUserModel> toggleUserStatus(int id, bool isActive) async {
    final updated = await updateUser(id, {'is_active': isActive});
    _logAudit(
      action: isActive ? 'ACTIVATE_USER' : 'DEACTIVATE_USER',
      entityType: 'user',
      entityId: 'USR-$id',
      details: '${isActive ? "Activated" : "Disabled (soft-delete)"} access for ${updated.name}',
    );
    return updated;
  }

  void _logAudit({
    required String action,
    required String entityType,
    required String entityId,
    required String details,
  }) {
    _sessionAuditLogs.insert(
      0,
      AuditEntryModel(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        userId: 1,
        userName: 'Administrator',
        userRole: 'admin',
        action: action,
        entityType: entityType,
        entityId: entityId,
        details: details,
        ipAddress: '127.0.0.1',
        userAgent: 'Steriqore Clinical Authority Admin',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<AuditEntryModel>> getAuditTrail({
    String? search,
    String? action,
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<AuditEntryModel> allEntries = List.from(_sessionAuditLogs);

    // 1. Fetch live Usages from Backend API (/usages)
    try {
      final response = await dioClient.get(ApiConstants.usages);
      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        list = data['data'] as List;
      }

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          DateTime parseDate(dynamic val) {
            if (val == null) return DateTime.now();
            return DateTime.tryParse(val.toString()) ?? DateTime.now();
          }

          final uId = item['id']?.toString() ?? '1';
          final pName = item['practitioner_name'] as String? ?? 'Practitioner';
          final patName = item['patient_name'] as String? ?? item['patient']?['first_name'] ?? 'Patient';
          final lCode = item['label_code'] as String? ?? item['label']?['code'] ?? 'LBL';

          allEntries.add(
            AuditEntryModel(
              id: 'AUD-USG-$uId',
              userId: int.tryParse(item['practitioner_id']?.toString() ?? '2') ?? 2,
              userName: pName,
              userRole: 'practitioner',
              action: 'RECORD_USAGE',
              entityType: 'instrument_usage',
              entityId: lCode,
              details: 'Applied instrument $lCode on patient $patName',
              ipAddress: '127.0.0.1',
              userAgent: 'Steriqore Mobile Scanner',
              timestamp: parseDate(item['used_at'] ?? item['created_at']),
            ),
          );
        }
      }
    } catch (_) {}

    // 2. Fetch live Alerts from Backend API (/alerts)
    try {
      final response = await dioClient.get(ApiConstants.alerts);
      final dynamic data = response.data;
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data') && data['data'] is List) {
        list = data['data'] as List;
      }

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          DateTime parseDate(dynamic val) {
            if (val == null) return DateTime.now();
            return DateTime.tryParse(val.toString()) ?? DateTime.now();
          }

          final aId = item['id']?.toString() ?? '1';
          final title = item['title'] as String? ?? item['message'] as String? ?? 'Sterilization Alert';
          final type = item['type'] as String? ?? 'WARNING';

          allEntries.add(
            AuditEntryModel(
              id: 'AUD-ALT-$aId',
              userId: 1,
              userName: 'System Monitor',
              userRole: 'system',
              action: type.toUpperCase(),
              entityType: 'alert',
              entityId: 'ALT-$aId',
              details: title,
              ipAddress: '127.0.0.1',
              userAgent: 'Steriqore Core Daemon',
              timestamp: parseDate(item['created_at']),
            ),
          );
        }
      }
    } catch (_) {}

    allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allEntries.where((a) {
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final match = a.action.toLowerCase().contains(q) ||
            a.userName.toLowerCase().contains(q) ||
            a.details.toLowerCase().contains(q) ||
            (a.entityId?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (action != null && action.isNotEmpty && action != 'all') {
        if (a.action.toLowerCase() != action.toLowerCase()) return false;
      }
      if (userId != null && a.userId != userId) {
        return false;
      }
      if (startDate != null && a.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && a.timestamp.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<CabinetSettingsModel> getCabinetSettings() async {
    try {
      final response = await dioClient.get('/organizations/current');
      final dynamic data = response.data;
      final map = (data is Map && data.containsKey('data')) ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;
      _cabinetSettings = CabinetSettingsModel.fromJson(map);
      return _cabinetSettings;
    } catch (_) {
      return _cabinetSettings;
    }
  }

  @override
  Future<CabinetSettingsModel> updateCabinetSettings(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put('/organizations/current', data: data);
      final dynamic resData = response.data;
      final map = (resData is Map && resData.containsKey('data')) ? resData['data'] as Map<String, dynamic> : resData as Map<String, dynamic>;
      _cabinetSettings = CabinetSettingsModel.fromJson(map);
    } catch (_) {
      _cabinetSettings = CabinetSettingsModel(
        id: _cabinetSettings.id,
        cabinetName: data['cabinet_name'] as String? ?? _cabinetSettings.cabinetName,
        cabinetCode: data['cabinet_code'] as String? ?? _cabinetSettings.cabinetCode,
        address: data['address'] as String? ?? _cabinetSettings.address,
        phone: data['phone'] as String? ?? _cabinetSettings.phone,
        email: data['email'] as String? ?? _cabinetSettings.email,
        dlcThresholdDays: data['dlc_threshold_days'] is int
            ? data['dlc_threshold_days'] as int
            : _cabinetSettings.dlcThresholdDays,
        lowStockThreshold: data['low_stock_threshold'] is int
            ? data['low_stock_threshold'] as int
            : _cabinetSettings.lowStockThreshold,
        enableBiometrics: data['enable_biometrics'] is bool
            ? data['enable_biometrics'] as bool
            : _cabinetSettings.enableBiometrics,
        autoSyncEnabled: data['auto_sync_enabled'] is bool
            ? data['auto_sync_enabled'] as bool
            : _cabinetSettings.autoSyncEnabled,
        primaryAutoclaveId: data['primary_autoclave_id'] as String? ?? _cabinetSettings.primaryAutoclaveId,
      );
    }

    _logAudit(
      action: 'UPDATE_SETTINGS',
      entityType: 'cabinet',
      entityId: _cabinetSettings.cabinetCode,
      details: 'Updated dental practice parameters and safety thresholds',
    );
    return _cabinetSettings;
  }
}
