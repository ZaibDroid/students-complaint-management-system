import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/batch_model.dart';
import '../../data/repositories/batch_repository.dart';

final batchesStreamProvider = StreamProvider<List<BatchModel>>((ref) {
  final repository = ref.watch(batchRepositoryProvider);
  return repository.getBatches();
});
