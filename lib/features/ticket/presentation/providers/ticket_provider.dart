import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_log_model.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/socket_service.dart';
import 'package:e_ticketing_helpdesk/features/ticket/data/repositories/ticket_repository.dart';
import 'package:e_ticketing_helpdesk/features/dashboard/presentation/providers/dashboard_provider.dart';

class TicketProvider extends ChangeNotifier {
  final TicketRepository _ticketRepository = TicketRepository();
  final _authService = Get.find<AuthService>();
  final _socketService = Get.find<SocketService>();

  final tickets = <TicketModel>[].obs;
  final comments = <CommentModel>[].obs;
  final ticketLogs = <TicketLogModel>[].obs;
  final selectedTicket = Rx<TicketModel?>(null);

  final isLoading = false.obs;
  final isLoadingComments = false.obs;
  final isLoadingLogs = false.obs;
  final isSubmitting = false.obs;
  final selectedFilter = 'all'.obs;

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final commentCtrl = TextEditingController();
  final selectedPriority = 'medium'.obs;
  final selectedCategory = 'Hardware'.obs;
  final selectedImages = <XFile>[].obs;

  final createFormKey = GlobalKey<FormState>();

  final categories = ['Hardware', 'Software', 'Network', 'Akun', 'Lainnya'];
  final priorities = ['low', 'medium', 'high', 'urgent'];

  void onInit() {
    loadTickets();
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _socketService.on('ticket_created', (data) {
      final user = _authService.currentUser.value;
      if (user == null) return;
      
      if (user.isAdmin || user.isHelpdesk || (user.isUser && data['created_by'] == user.id)) {
        loadTickets();
      }
    });

    _socketService.on('ticket_updated', (data) {
      if (selectedTicket.value?.id == data['id']) {
        loadTicketDetail(data['id']);
      }
      loadTickets();
    });

    _socketService.on('ticket_status_updated', (data) {
      final ticketId = data['ticket_id'];
      if (selectedTicket.value?.id == ticketId) {
        loadTicketDetail(ticketId);
        
        Get.snackbar(
          'Status Tiket Diperbarui',
          'Tiket #${ticketId.toString().substring(0, 5)} kini berstatus: ${data['new_status']}',
          backgroundColor: Colors.indigo,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
      loadTickets();
      _refreshDashboard();
    });

    _socketService.on('comment_added', (data) {
      if (selectedTicket.value?.id == data['ticketId']) {
        final newComment = CommentModel.fromJson(data['comment']);
        if (!comments.any((c) => c.id == newComment.id)) {
          comments.add(newComment);
          notifyListeners();
        }
      }
    });
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    notifyListeners();
    loadTickets();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    notifyListeners();
  }

  void setPriority(String priority) {
    selectedPriority.value = priority;
    notifyListeners();
  }

  void _refreshDashboard() {
    try {
      if (Get.isRegistered<DashboardProvider>()) {
        Get.find<DashboardProvider>().loadStats();
      }
    } catch (e) {
      print('Error refreshing dashboard: $e');
    }
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    notifyListeners();
    try {
      final user = _authService.currentUser.value;
      String? createdBy;
      String? assignedTo;

      if (user != null) {
        if (user.isUser) {
          createdBy = user.id;
        } else if (user.isTechnicalSupport && !user.isAdmin) {
          assignedTo = user.id;
        }
      }

      final status = selectedFilter.value == 'all' ? null : selectedFilter.value;
      
      tickets.value = await _ticketRepository.getTickets(
        createdBy: createdBy,
        assignedTo: assignedTo,
        status: status,
      );
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<void> loadTicketDetail(String id) async {
    isLoading.value = true;
    notifyListeners();
    isLoadingComments.value = true;
    isLoadingLogs.value = true;
    notifyListeners();
    try {
      selectedTicket.value = await _ticketRepository.getTicketById(id);
      comments.value = await _ticketRepository.getComments(id);
      ticketLogs.value = await _ticketRepository.getTicketLogs(id);
    } finally {
      isLoading.value = false;
      isLoadingComments.value = false;
      isLoadingLogs.value = false;
      notifyListeners();
    }
  }

  Future<void> pickImages(ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          final File file = File(pickedFile.path);
          final int fileSize = await file.length();
          
          if (fileSize > 5 * 1024 * 1024) {
            Get.snackbar(
              'File Terlalu Besar',
              'Ukuran gambar maksimal adalah 5MB. Gambar Anda: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)}MB',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          selectedImages.add(pickedFile);
          notifyListeners();
        }
      } else {
        final List<XFile> pickedFiles = await picker.pickMultiImage(
          imageQuality: 80,
        );

        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            final int fileSize = await File(file.path).length();
            if (fileSize <= 5 * 1024 * 1024) {
              selectedImages.add(file);
            } else {
              Get.snackbar(
                'File Terlalu Besar',
                'Beberapa gambar dilewati karena ukuran melebihi 5MB.',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> createTicket() async {
    if (!createFormKey.currentState!.validate()) return;
    final user = _authService.currentUser.value;
    if (user == null) return;

    isSubmitting.value = true;
    notifyListeners();
    try {
      await _ticketRepository.createTicket(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        priority: selectedPriority.value,
        category: selectedCategory.value,
        createdBy: user.id,
        createdByName: user.name,
        attachments: selectedImages.map((e) => e.path).toList(),
      );

      _clearForm();
      Get.back();
      loadTickets();
      _refreshDashboard();
      Get.snackbar('Berhasil', 'Tiket bantuan telah berhasil dibuat.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat tiket: $e');
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> assignTicket(String ticketId, String assignedTo, String assignedToName) async {
    final actor = _authService.currentUser.value;
    if (actor == null || !actor.canAssign) return;

    isSubmitting.value = true;
    notifyListeners();
    try {
      final success = await _ticketRepository.assignTicket(
        ticketId: ticketId,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        changedBy: actor.id,
        changedByName: actor.name,
      );
      
      if (success) {
        await loadTicketDetail(ticketId);
        loadTickets();
        _refreshDashboard();
        Get.snackbar('Berhasil', 'Tiket telah ditugaskan ke $assignedToName');
      }
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> unassignTicket(String ticketId) async {
    final actor = _authService.currentUser.value;
    if (actor == null) return;

    isSubmitting.value = true;
    notifyListeners();
    try {
      final success = await _ticketRepository.unassignTicket(ticketId);
      if (success) {
        await loadTicketDetail(ticketId);
        loadTickets();
        _refreshDashboard();
        Get.snackbar('Berhasil', 'Penugasan teknisi telah dibatalkan.');
      }
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String ticketId, String status, {String? note}) async {
    final actor = _authService.currentUser.value;
    if (actor == null) return;

    if (actor.isTechnicalSupport && status != 'resolved' && !actor.isAdmin) {
      Get.snackbar('Akses Ditolak', 'Teknisi hanya bisa set ke Selesai Penanganan.');
      return;
    }

    isSubmitting.value = true;
    notifyListeners();
    try {
      final success = await _ticketRepository.updateTicketStatus(
        ticketId: ticketId,
        status: status,
        changedBy: actor.id,
        changedByName: actor.name,
        note: note,
      );

      if (success) {
        await loadTicketDetail(ticketId);
        loadTickets();
        _refreshDashboard();
        Get.snackbar('Berhasil', 'Status tiket diperbarui.');
      }
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    isSubmitting.value = true;
    notifyListeners();
    try {
      final success = await _ticketRepository.deleteTicket(ticketId);
      if (success) {
        Get.back(); // Kembali dari detail
        loadTickets();
        _refreshDashboard();
        Get.snackbar('Berhasil', 'Tiket telah dihapus.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus tiket: $e');
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  void prepareReply(String username) {
    commentCtrl.text = "@$username ";
    commentCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: commentCtrl.text.length),
    );
    notifyListeners();
  }

  Future<void> addComment(String ticketId) async {
    final user = _authService.currentUser.value;
    if (user == null || commentCtrl.text.trim().isEmpty) return;

    isSubmitting.value = true;
    notifyListeners();
    try {
      final comment = await _ticketRepository.addComment(
        ticketId: ticketId,
        userId: user.id,
        userName: user.name,
        userRole: user.role,
        content: commentCtrl.text.trim(),
      );
      if (!comments.any((c) => c.id == comment.id)) {
          comments.add(comment);
      }
      commentCtrl.clear();
      notifyListeners();
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    selectedPriority.value = 'medium';
    selectedCategory.value = 'Hardware';
    selectedImages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    commentCtrl.dispose();
    super.dispose();
  }
}
