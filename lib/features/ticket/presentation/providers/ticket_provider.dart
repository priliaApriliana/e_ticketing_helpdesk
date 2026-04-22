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
  final priorities = ['low', 'medium', 'high'];

  void setCategory(String category) {
    selectedCategory.value = category;
    notifyListeners();
  }

  void setPriority(String priority) {
    selectedPriority.value = priority;
    notifyListeners();
  }

  void onInit() {
    loadTickets();
  }

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
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
    try {
      comments.value = await _ticketRepository.getComments(id);
    } finally {
      isLoadingComments.value = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    notifyListeners();
    loadTickets();
  }

  Future<void> pickImages(ImageSource source) async {
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final images = await picker.pickMultiImage();
      selectedImages.addAll(images);
      notifyListeners();
    } else {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        selectedImages.add(image);
        notifyListeners();
      }
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    notifyListeners();
  }

  Future<void> createTicket() async {
    if (!createFormKey.currentState!.validate()) return;
    final user = _authService.currentUser.value;
    if (user == null) return;

    isSubmitting.value = true;
    notifyListeners();
    try {
      final ticket = await _ticketRepository.createTicket(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        priority: selectedPriority.value,
        category: selectedCategory.value,
        createdBy: user.id,
        createdByName: user.name,
      );

      _notifyTicketCreated(ticket, user);

      Get.back();
      loadTickets();
      Get.snackbar(
        'Berhasil',
        'Tiket berhasil dibuat',
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        snackPosition: SnackPosition.BOTTOM,
      );
      _clearForm();
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  void prepareReply(String username) {
    final mention = '@$username ';
    if (commentCtrl.text.trim().isEmpty) {
      commentCtrl.text = mention;
    } else if (!commentCtrl.text.trimLeft().startsWith('@$username')) {
      commentCtrl.text = '$mention${commentCtrl.text}';
    }
    commentCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: commentCtrl.text.length),
    );
  }

  Future<void> addComment(String ticketId) async {
    if (commentCtrl.text.trim().isEmpty) return;
    final user = _authService.currentUser.value;
    if (user == null) return;

    final ticket = await _ticketRepository.getTicketById(ticketId);

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
      notifyListeners();

      if (ticket != null) {
        _notifyCommentAdded(ticket, user);
      }

      commentCtrl.clear();
      loadTickets();
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> assignTicket(String ticketId, String assignedTo, String assignedToName) async {
    final actor = _authService.currentUser.value;
    if (actor == null) return;

    final ticket = await _ticketRepository.getTicketById(ticketId);
    if (ticket == null) return;

    final isAdmin = actor.isAdmin;
    final isHelpdesk = actor.role == 'helpdesk';

    if (!isAdmin && !isHelpdesk) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya helpdesk atau admin yang bisa assign tiket.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_authService.isTechnicalSupportId(assignedTo)) {
      Get.snackbar(
        'Akses Ditolak',
        'Tiket hanya boleh di-assign ke Technical Support.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isAdmin && ticket.assignedTo != null && ticket.assignedTo != assignedTo) {
      Get.snackbar(
        'Akses Ditolak',
        'Re-assign tiket hanya bisa dilakukan oleh admin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    notifyListeners();
    try {
      final previousAssigneeId = ticket.assignedTo;
      final success = await _ticketRepository.assignTicket(
        ticketId: ticketId,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
      );
      if (!success) return;

      _notifyAssigned(
        ticket: ticket,
        actorName: actor.name,
        assignedTo: assignedTo,
        assignedToName: assignedToName,
        previousAssigneeId: previousAssigneeId,
      );

      await loadTicketDetail(ticketId);
      loadTickets();
      Get.snackbar(
        'Berhasil',
        'Tiket sedang ditangani technical support: $assignedToName',
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> unassignTicket(String ticketId) async {
    final actor = _authService.currentUser.value;
    if (actor == null || !actor.isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya admin yang bisa membatalkan assign.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ticketBefore = await _ticketRepository.getTicketById(ticketId);

    isSubmitting.value = true;
    notifyListeners();
    try {
      final success = await _ticketRepository.unassignTicket(ticketId);
      if (!success) return;

      if (ticketBefore != null) {
        _notifyUnassigned(ticketBefore, actor.name);
      }

      await loadTicketDetail(ticketId);
      loadTickets();
      Get.snackbar(
        'Berhasil',
        'Assign dibatalkan. Tiket kembali ke status menunggu helpdesk.',
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String ticketId, String status) async {
    final actor = _authService.currentUser.value;
    if (actor == null || !actor.isStaff) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya staff yang bisa mengubah status.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ticket = await _ticketRepository.getTicketById(ticketId);
    if (ticket == null) return;

    final isAdmin = actor.isAdmin;
    final isHelpdesk = actor.role == 'helpdesk';
    final isTechnicalSupport = actor.isTechnicalSupport;

    if (isTechnicalSupport && status != 'resolved') {
      Get.snackbar(
        'Akses Ditolak',
        'Technical Support hanya bisa set ke Selesai Teknis.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isTechnicalSupport && ticket.assignedTo != actor.id) {
      Get.snackbar(
        'Akses Ditolak',
        'Anda hanya bisa mengubah tiket yang di-assign ke Anda.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isHelpdesk && status != 'in_progress') {
      Get.snackbar(
        'Akses Ditolak',
        'Helpdesk hanya bisa set ke Diproses.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isAdmin && status == 'closed') {
      Get.snackbar(
        'Akses Ditolak',
        'Menutup tiket hanya bisa dilakukan admin.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _ticketRepository.updateTicketStatus(ticketId, status);
    _notifyStatusUpdated(ticket, status, actor.name, actor.id);

    await loadTicketDetail(ticketId);
    loadTickets();
    Get.snackbar(
      'Berhasil',
      'Status tiket diperbarui',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _notifyTicketCreated(TicketModel ticket, dynamic actor) {
    _notificationService.addForUsers(
      recipientUserIds: {ticket.createdBy},
      title: 'Tiket Berhasil Dibuat',
      message: 'Tiket ${ticket.id} berhasil dibuat dan menunggu helpdesk.',
      ticketId: ticket.id,
      type: 'ticket_created_self',
    );

    _notificationService.addForUsers(
      recipientUserIds: {..._authService.adminIds, ..._authService.helpdeskIds},
      title: 'Tiket Baru',
      message: '${actor.name} membuat tiket ${ticket.id}.',
      ticketId: ticket.id,
      type: 'ticket_created',
      excludeUserId: actor.id,
    );
  }

  void _notifyCommentAdded(TicketModel ticket, dynamic actor) {
    _notificationService.addForUsers(
      recipientUserIds: {
        ticket.createdBy,
        if (ticket.assignedTo != null) ticket.assignedTo!,
        ..._authService.adminIds,
        ..._authService.helpdeskIds,
      },
      title: 'Komentar Baru',
      message: '${actor.name} menambahkan komentar pada tiket ${ticket.id}.',
      ticketId: ticket.id,
      type: 'comment_added',
      excludeUserId: actor.id,
    );
  }

  void _notifyAssigned({
    required TicketModel ticket,
    required String actorName,
    required String assignedTo,
    required String assignedToName,
    String? previousAssigneeId,
  }) {
    _notificationService.addForUsers(
      recipientUserIds: {assignedTo},
      title: 'Tiket Di-assign ke Anda',
      message: '$actorName menugaskan tiket ${ticket.id} ke Anda.',
      ticketId: ticket.id,
      type: 'ticket_assigned',
    );

    _notificationService.addForUsers(
      recipientUserIds: {ticket.createdBy},
      title: 'Tiket Mulai Ditangani',
      message: 'Tiket ${ticket.id} sedang ditangani oleh $assignedToName.',
      ticketId: ticket.id,
      type: 'ticket_assigned_creator',
    );

    if (previousAssigneeId != null && previousAssigneeId != assignedTo) {
      _notificationService.addForUsers(
        recipientUserIds: {previousAssigneeId},
        title: 'Assign Dipindahkan',
        message: 'Anda tidak lagi menangani tiket ${ticket.id}.',
        ticketId: ticket.id,
        type: 'ticket_reassigned_out',
      );
    }
  }

  void _notifyUnassigned(TicketModel ticket, String actorName) {
    _notificationService.addForUsers(
      recipientUserIds: {
        ticket.createdBy,
        if (ticket.assignedTo != null) ticket.assignedTo!,
      },
      title: 'Assign Dibatalkan',
      message: '$actorName membatalkan assign tiket ${ticket.id}.',
      ticketId: ticket.id,
      type: 'ticket_unassigned',
    );
  }

  void _notifyStatusUpdated(TicketModel ticket, String status, String actorName, String actorId) {
    final recipients = <String>{
      ticket.createdBy,
      if (ticket.assignedTo != null) ticket.assignedTo!,
      ..._authService.adminIds,
      ..._authService.helpdeskIds,
    };

    _notificationService.addForUsers(
      recipientUserIds: recipients,
      title: 'Status Tiket Diperbarui',
      message:
          '$actorName mengubah status tiket ${ticket.id} menjadi ${_statusLabel(status)}.',
      ticketId: ticket.id,
      type: 'status_updated',
      excludeUserId: actorId,
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Menunggu Helpdesk';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai Teknis';
      case 'closed':
        return 'Selesai';
      default:
        return status;
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

  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    commentCtrl.dispose();
  }
}







