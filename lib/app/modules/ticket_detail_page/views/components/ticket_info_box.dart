import 'package:flutter/widgets.dart';

import '../../../../common/app_color.dart';

Container ticketInfoBox(ticket) {
    return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColorList.ContainerBackground,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColorList.ContainerShadow,
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        ticketInfoRow('Ticket Reference', ticket.tref1.trim() ?? '---'),
        ticketInfoRow('Serial No', ticket.serialNo1.trim() ?? '---'),
        ticketInfoRow('Model No', ticket.model_number1 ?? '---'),
        ticketInfoRow('Status', ticket.state1 ?? '---'),
        ticketInfoRow('Fault Area', ticket.faultArea1 ?? '---'),
        ticketInfoRow('Description', ticket.Description1?? '---'),
      ],
    ),
  );
  }

Widget ticketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }