import 'package:climb_scale/services/weight_scale_service.dart';
import 'package:equatable/equatable.dart';

class ConnectionInformation extends Equatable {
  final ScanResult result;
  ConnectionStatus initialConnection;
  final Stream<ConnectionStatus> connection;

  ConnectionInformation({
    required this.result,
    required this.initialConnection,
    required this.connection,
  });

  @override
  List<Object?> get props => [result, initialConnection, connection];
}
