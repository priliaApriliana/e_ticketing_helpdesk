import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:e_ticketing_helpdesk/features/ticket/data/models/ticket_model.dart';
import 'package:e_ticketing_helpdesk/core/services/auth_service.dart';
import 'package:e_ticketing_helpdesk/core/services/notification_service.dart';
import 'package:e_ticketing_helpdesk/features/ticket/data/repositories/ticket_repository.dart';

class TicketProvider extends ChangeNotifier {
  final TicketRepository _ticketRepository = TicketRepository();
  final _authService = Get.find<AuthService>();
  final _notificationService = Get.find<NotificationService>();

  final tickets = <TicketModel>[].obs;
  final comments = <CommentModel>[].obs;
  final selectedTicket = Rx<TicketModel?>(null);

  final isLoading = false.obs;
  final isLoadingComments = false.obs;
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
  }

  // --- Filter Methods ---
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

  // --- Ticket Loading ---
  Future<void> loadTickets() async {
    isLoading.value = true;
    notifyListeners();
    try {
      final user = _authService.currentUser.value;
      final userId = user?.isUser == true ? user?.id : null;
      final status = selectedFilter.value == 'all' ? null : selectedFilter.value;
      
      tickets.value = await _ticketRepository.getTickets(
        userId: userId,
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
    notifyListeners();
    try {
      selectedTicket.value = await _ticketRepository.getTicketById(id);
      comments.value = await _ticketRepository.getComments(id);
    } finally {
      isLoading.value = false;
      isLoadingComments.value = false;
      notifyListeners();
    }
  }

  // --- Image Picking ---
  Future<void> pickImages(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedImages.addAll(images);
      }
    } else {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        selectedImages.add(image);
      }
    }
    notifyListeners();
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    notifyListeners();
  }

  // --- Ticket Actions ---
  // Kita pastikan createTicket adalah fungsi yang bisa dipanggil tanpa parameter
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
      );
      
      if (success) {
        await loadTicketDetail(ticketId);
        loadTickets();
        Get.snackbar('Berhasil', 'Tiket telah ditugaskan ke $assignedToName');
      }
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> unassignTicket(String ticketId) async {
    isSubmitting.value = true;
    notifyListeners();
    try {
      final success = await _ticketRepository.unassignTicket(ticketId);
      if (success) {
        await loadTicketDetail(ticketId);
        loadTickets();
        Get.snackbar('Berhasil', 'Penugasan teknisi telah dibatalkan.');
      }
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String ticketId, String status) async {
    final actor = _authService.currentUser.value;
    if (actor == null) return;

    if (actor.isTechnicalSupport && status != 'resolved') {
      Get.snackbar('Akses Ditolak', 'Teknisi hanya bisa set ke Selesai Teknis.');
      return;
    }

    await _ticketRepository.updateTicketStatus(ticketId, status);
    await loadTicketDetail(ticketId);
    loadTickets();
    Get.snackbar('Berhasil', 'Status tiket diperbarui.');
  }

  // --- Comment Actions ---
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
      comments.add(comment);
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
