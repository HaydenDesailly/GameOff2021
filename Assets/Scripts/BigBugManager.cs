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
    private GameObject BigBug;

    [SerializeField]
    private bool DoTheThing;

    private int EnvironmentLayerId = 6;

    float timer = 11f;

    public List<Node> Nodes { get; private set; } = new List<Node>();

    private void Awake()
    {
        if (DoTheThing)
        {
            //assembling point nodes based on mesh vertices (and storing normals for rotation of pathing entities)
            var environmentObjects = FindGameObjectsInLayer(EnvironmentLayerId);
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

            //foreach (var node in Nodes)
            //{
            //    Instantiate(BigBug, node.Point, Quaternion.FromToRotation(node.Point, node.Normal), null);
            //}
        }
    }

    //private void Update()
    //{
    //    timer += Time.deltaTime;

    //    if (timer > 10f)
    //    {
    //        timer = 0f;
    //        foreach (var node in Nodes)
    //        {
    //            foreach (var child in node.Children)
    //            {
    //                Debug.DrawLine(node.Point, child.Point, Color.red, 10f);
    //            }
    //        }
    //    }
    //}

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
