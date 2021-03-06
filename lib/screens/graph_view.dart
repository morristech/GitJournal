import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/graph.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';

class GraphViewScreen extends StatefulWidget {
  @override
  _GraphViewScreenState createState() => _GraphViewScreenState();
}

class _GraphViewScreenState extends State<GraphViewScreen> {
  Graph graph;

  @override
  Widget build(BuildContext context) {
    if (graph == null) {
      var rootFolder = Provider.of<NotesFolderFS>(context);
      setState(() {
        graph = Graph.fromFolder(rootFolder);
        graph.addListener(() {
          setState(() {});
        });
      });
      return Container(width: 2500, height: 2500);
    }

    return GraphView(graph);
  }
}

class GraphView extends StatefulWidget {
  final Graph graph;

  GraphView(this.graph);

  @override
  _GraphViewState createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  @override
  void initState() {
    super.initState();

    widget.graph.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    children.add(CustomPaint(painter: GraphEdgePainter(widget.graph)));

    for (var node in widget.graph.nodes) {
      var w = Positioned(
        child: GestureDetector(
          child: NodeWidget(node),
          onPanStart: (details) {
            node.x = details.globalPosition.dx;
            node.y = details.globalPosition.dy;
            node.pressed = true;

            widget.graph.notify();
            print("Pan start ${node.label} $details");
          },
          onPanEnd: (DragEndDetails details) {
            print("Pan end ${node.label} $details");
            node.pressed = false;
            widget.graph.notify();
          },
          onPanUpdate: (details) {
            node.x = details.globalPosition.dx;
            node.y = details.globalPosition.dy;

            widget.graph.notify();
            print("Pan update ${node.label} ${details.globalPosition}");
          },
        ),
        left: node.x - 25,
        top: node.y - 25,
      );
      children.add(w);
    }

    return Scrollbar(
      child: SingleChildScrollView(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              width: 2500,
              height: 2500,
              child: Stack(
                children: children,
                fit: StackFit.expand,
              ),
            ),
            scrollDirection: Axis.horizontal,
          ),
        ),
        scrollDirection: Axis.vertical,
      ),
    );
  }
}

class GraphEdgePainter extends CustomPainter {
  final Graph graph;

  GraphEdgePainter(this.graph) : super(repaint: graph);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all the edges
    for (var edge in graph.edges) {
      var strokeWitdth = 2.5;
      if (edge.a.pressed || edge.b.pressed) {
        strokeWitdth *= 2;
      }

      canvas.drawLine(
        Offset(edge.a.x, edge.a.y),
        Offset(edge.b.x, edge.b.y),
        Paint()
          ..color = Colors.green
          ..strokeWidth = strokeWitdth,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class NodeWidget extends StatelessWidget {
  final Node node;

  NodeWidget(this.node);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.subtitle1.copyWith(fontSize: 8.0);

    var label = node.label;
    if (label.startsWith('docs/')) {
      label = label.substring(5);
    }
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        Text(label, style: textStyle),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
