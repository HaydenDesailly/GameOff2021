using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class BigBugManager : MonoBehaviour
{
    public static BigBugManager Instance
    {
        get { return _instance ??= FindObjectOfType<BigBugManager>() ?? new BigBugManager { }; }
    }
    private static BigBugManager _instance;

    [SerializeField]
    private GameObject _bigBug;

    [SerializeField]
    private bool _spawnBugs;

    private int _environmentLayerId = 6;

    [SerializeField]
    private float _bugSpawnPeriod = 10f;

    private float _timer;

    public List<Node> Nodes { get; private set; } = new List<Node>();

    private void Awake()
    {
        _timer = _bugSpawnPeriod;

        if (_spawnBugs)
        {
            //assembling point nodes based on mesh vertices (and storing normals for rotation of pathing entities)
            var environmentObjects = FindGameObjectsInLayer(_environmentLayerId);
            foreach (var environmentObject in environmentObjects)
            {
                Matrix4x4 localToWorld = environmentObject.transform.localToWorldMatrix;

                var meshfilter = environmentObject.GetComponent<MeshFilter>();
                if (meshfilter != null)
                {
                    for (int i = 0; i < meshfilter.mesh.vertices.Length; ++i)
                    {
                        var vertex = localToWorld.MultiplyPoint3x4(meshfilter.mesh.vertices[i]);
                        var normal = localToWorld.MultiplyPoint3x4(meshfilter.mesh.normals[i]);

                        Nodes.Add(new Node
                        {
                            mesh = meshfilter.mesh,
                            vertexId = i,
                            Point = vertex,
                            Normal = normal
                        });
                    }
                }
            }

            //linking nodes to each other based on mesh triangles
            foreach (var node in Nodes)
            {
                var triangles = node.mesh.triangles;
                if (triangles.Length > 1)
                {
                    for (int i = 0; i < triangles.Length; i++)
                    {
                        if (triangles[i] == node.vertexId)
                        {
                            var position = i % 3;
                            if (position == 0)
                            {
                                var destinationNodeA = Nodes.FirstOrDefault(n => n.vertexId == triangles[i + 1]);
                                node.Children.Add(destinationNodeA);
                                destinationNodeA.Children.Add(node);

                                var destinationNodeB = Nodes.FirstOrDefault(n => n.vertexId == triangles[i + 2]);
                                node.Children.Add(destinationNodeB);
                                destinationNodeB.Children.Add(node);
                            }
                            else if (position == 1)
                            {
                                var destinationNodeA = Nodes.FirstOrDefault(n => n.vertexId == triangles[i - 1]);
                                node.Children.Add(destinationNodeA);
                                destinationNodeA.Children.Add(node);

                                var destinationNodeB = Nodes.FirstOrDefault(n => n.vertexId == triangles[i + 1]);
                                node.Children.Add(destinationNodeB);
                                destinationNodeB.Children.Add(node);
                            }
                            else if (position == 2)
                            {
                                var destinationNodeA = Nodes.FirstOrDefault(n => n.vertexId == triangles[i - 1]);
                                node.Children.Add(destinationNodeA);
                                destinationNodeA.Children.Add(node);

                                var destinationNodeB = Nodes.FirstOrDefault(n => n.vertexId == triangles[i - 2]);
                                node.Children.Add(destinationNodeB);
                                destinationNodeB.Children.Add(node);
                            }
                        }
                    }
                }
            }

            //merge close nodes together (will orphan the other close nodes, which will then be dumped)
            foreach (var node in Nodes)
            {
                foreach (var node2 in Nodes)
                {
                    if (node != node2 && Vector3.Distance(node.Point, node2.Point) < 0.1f)
                    {
                        //merge
                        if (node2.Children.Count() > 0)
                        {
                            node.Children.AddRange(node2.Children);

                            //swap children's links
                            foreach (var child in node2.Children)
                            {
                                child.Children = child.Children.Where(c => c != node2).ToList();
                                child.Children.Add(node);
                            }

                            node2.Children.Clear();
                        }
                    }
                }
            }

            //dump any vertices which dont have any edges to link to
            Nodes = Nodes.Where(n => n.Children.Count > 0).ToList();
        }
    }

    private void Update()
    {
        if (_spawnBugs)
        {
            _timer -= Time.deltaTime;

            if (_timer < 0f)
            {
                _timer = _bugSpawnPeriod;

                Instantiate(_bigBug, Vector3.zero, Quaternion.identity, null);
            }
        }
    }

    private List<GameObject> FindGameObjectsInLayer(int layer)
    {
        var gameObjects = FindObjectsOfType(typeof(GameObject)) as GameObject[];
        var environmentGameObjects = new List<GameObject>();
        for (int i = 0; i < gameObjects.Length; i++)
        {
            if (gameObjects[i].layer == layer)
            {
                environmentGameObjects.Add(gameObjects[i]);
            }
        }
        if (environmentGameObjects.Count == 0)
        {
            return null;
        }
        return environmentGameObjects;
    }

    public class Node
    {
        public Mesh mesh;
        public int vertexId;
        public Vector3 Point;
        public Vector3 Normal;
        public List<Node> Children = new List<Node>();
    }
}
