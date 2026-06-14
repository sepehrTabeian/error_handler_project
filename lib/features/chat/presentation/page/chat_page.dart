import 'package:error_handler_project/features/chat/domain/entities/chat_message_entity.dart';
import 'package:error_handler_project/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:error_handler_project/features/chat/presentation/bloc/chat_event.dart';
import 'package:error_handler_project/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatStarted());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('چت'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<ChatBloc>().add(
                  const ChatPendingSyncRequested(),
                );
              },
              icon: const Icon(Icons.sync),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];

                      return ListTile(
                        title: Text(message.text),
                        subtitle: Text(
                          switch (message.status) {
                            MessageSendStatus.pending => 'در انتظار ارسال',
                            MessageSendStatus.sent => 'ارسال شده',
                            MessageSendStatus.failed => 'ارسال ناموفق',
                          },
                        ),
                        trailing: switch (message.status) {
                          MessageSendStatus.pending =>
                          const Icon(Icons.schedule),
                          MessageSendStatus.sent =>
                          const Icon(Icons.done),
                          MessageSendStatus.failed =>
                          const Icon(Icons.error_outline),
                        },
                      );
                    },
                  );
                },
              ),
            ),
            _ChatInput(controller: controller),
          ],
        ),
      ),
    );
  }
}
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;

  const _ChatInput({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'پیام خود را بنویسید...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final text = controller.text;

              context.read<ChatBloc>().add(
                ChatMessageSubmitted(text),
              );

              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}