import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ticket_provider.dart';
import '../widgets/create_ticket_widgets.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<TicketProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          const CreateTicketBackdrop(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                const CreateTicketTopBar(),
                const SizedBox(height: 18),
                const CreateTicketHeroPanel(),
                const SizedBox(height: 16),
                CreateTicketFormPanel(controller: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
