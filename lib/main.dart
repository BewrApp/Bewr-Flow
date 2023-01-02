import 'package:flow_graph/flow_graph.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GraphNode<FamilyNode> root;
  final Axis _direction = Axis.horizontal;
  final bool _centerLayout = false;

  final List<GraphNode<FamilyNode>> nodes = [
    GraphNode<FamilyNode>(data: FamilyNode(name: 'Node 1'), isRoot: true),
    GraphNode<FamilyNode>(data: FamilyNode(name: 'Node 2'), isRoot: true),
    GraphNode<FamilyNode>(data: FamilyNode(name: 'Node 3'), isRoot: true),
  ];

  @override
  void initState() {
    root = nodes[0];
    nodes[0].addNext(nodes[1]);
    nodes[1].addNext(nodes[2]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flow Graph'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final node = GraphNode<FamilyNode>(
                  data: FamilyNode(name: 'Node ${nodes.length + 1}'),
                );
                nodes.add(node);
                root.addNext(node);
                // print(nodes.length);
                setState(() {});
              },
            ),
          ],
        ),
        // https://stackoverflow.com/questions/63297070/how-to-do-a-background-grid-color
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            final h = Container(
              width: 2,
              height: height,
              color: Colors.grey.withOpacity(0.2),
            );
            final v = Container(
              width: width,
              height: 2,
              color: Colors.grey.withOpacity(0.2),
            );
            return Stack(
              children: <Widget>[
                ...List.generate(
                  (width / 60).round(),
                  (index) => Positioned(left: index * 60, child: h),
                ),
                ...List.generate(
                  (height / 60).round(),
                  (index) => Positioned(top: index * 60, child: v),
                ),
                DraggableFlowGraphView(
                  root: root,
                  direction: _direction,
                  centerLayout: _centerLayout,
                  willConnect: (node) => true,
                  willAccept: (node) => true,
                  builder: (context, node) {
                    return CustomNodeWidget(
                      node: node,
                      onDelete: () => {
                        node.deleteSelf(),
                        setState(() {}),
                        nodes.remove(node),
                        //nodes.length,
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class FamilyNode {
  FamilyNode({
    required this.name,
    this.singleChild = true,
    this.multiParent = false,
  });

  String name;
  bool singleChild;
  bool multiParent;
}

class CustomNodeWidget extends StatelessWidget {
  final GraphNode<FamilyNode> node;
  final Function onDelete;

  const CustomNodeWidget({
    super.key,
    required this.node,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            node.data!.name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    onDelete();
                  },
                )
              ];
            },
          ),
        ],
      ),
    );
  }
}
