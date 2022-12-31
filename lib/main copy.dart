import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FlowEditor(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Node {
  double x;
  double y;
  int id;
  String label;
  List<Connector> inputs = [];
  List<Connector> outputs = [];
  Offset canvasOffset;
  void Function(double dx, double dy) updatePosition;

  Node({
    required this.id,
    this.x = 0,
    this.y = 0,
    this.label = 'Node',
    required this.canvasOffset,
    required this.updatePosition,
  });

  Widget buildWidget(BuildContext context) {
    return Positioned(
      left: x + canvasOffset.dx,
      top: y + canvasOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          updatePosition(details.delta.dx, details.delta.dy);
        },
        child: Container(
          width: 200,
          height: 100,
          color: Colors.white,
          child: Column(
            children: [
              Text('Node $id'),
              ...inputs.map((input) => input.buildWidget(context)),
              ...outputs.map((output) => output.buildWidget(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class FlowEditor extends StatefulWidget {
  @override
  _FlowEditorState createState() => _FlowEditorState();
}

class _FlowEditorState extends State<FlowEditor> {
  List<Node> nodes = [];
  Offset canvasOffset = Offset(0, 0);
  int nodeIdCounter = 1;

  void updateNodePosition(int nodeId, double dx, double dy) {
    setState(() {
      var node = nodes.firstWhere((node) => node.id == nodeId);
      node.x += dx;
      node.y += dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Draw the canvas
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                canvasOffset += details.delta;
              });
            },
            child: Container(
              color: Colors.grey[200],
            ),
          ),
          // Draw the nodes and connectors
          ...nodes.map((node) {
            node.canvasOffset = canvasOffset;
            node.updatePosition = (dx, dy) => updateNodePosition(node.id, dx, dy);
            return node.buildWidget(context);
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            nodes.add(Node(
              x: canvasOffset.dx + 100,
              y: canvasOffset.dy + 100,
              id: nodeIdCounter++,
              canvasOffset: canvasOffset,
              updatePosition: (dx, dy) => updateNodePosition(nodeIdCounter, dx, dy),
            ));
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Connector {
  double x;
  double y;
  String label;

  Connector({
    this.x = 0,
    this.y = 0,
    this.label = 'Connector',
  });

  Widget buildWidget(BuildContext context) {
    return Container(
      width: 50,
      height: 25,
      color: Colors.grey[200],
      child: Text(label),
    );
  }
}