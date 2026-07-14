import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_command.dart';

class CommandBus {
  final _controller = StreamController<AppCommand>.broadcast();

  Stream<AppCommand> get stream => _controller.stream;

  void dispatch(AppCommand command) {
    _controller.add(command);
  }

  void dispose() {
    _controller.close();
  }
}

final commandBusProvider = Provider<CommandBus>((ref) {
  final bus = CommandBus();
  ref.onDispose(() => bus.dispose());
  return bus;
});
