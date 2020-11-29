import 'package:bsi_dart/bsi_dart.dart';

abstract class Services {
  /// Private generative constructor to prevent instantiation of this class.
  Services._();

  /// The root [BakeCodeService] of the **BakeCode Ecosystem**.
  ///
  /// It is strongly recommended that all services runs as a child or sub-child
  /// of this root service.
  static final BakeCode = ServiceReference.root('bakecode');

  /// The hardware service, where all hardware types can be instantiated to.
  static final Hardwares = BakeCode.child('hardwares');

  /// The **Broadcast [BakeCodeService]** for every BSI applications.
  ///
  /// Every BSI entity listens to this service.
  static final Broadcast = BakeCode.child('broadcast');

  /// The **Critical Events [BakeCodeService]** which every BSI entity listens to.
  static final CES = Broadcast.child('cems');

  /// The OsumPie [BakeCodeService].
  static final OsumPie = BakeCode.child('osumpie');
}