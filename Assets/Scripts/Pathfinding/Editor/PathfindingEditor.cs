using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector.Editor;
using Sirenix.OdinInspector;
using UnityEditor;

public class PathfindingEditor : OdinEditorWindow {


    [MenuItem("Game Jam/Pathfinding Editor")]
    static void OpenWindow() {
        GetWindow<PathfindingEditor>().Show();
    }

    [HideInInspector] public bool Active = false;

    [Button, HideIf("Active")]
    public void Activate() {
        Active = true;
    }

    [Button, ShowIf("Active")]
    public void Deactivate() {
        Active = false;
    }

    [Button]
    public void Refresh() {
        PathfindingGraph.Instance.RefreshNodes();
        PathfindingGraph.Instance.Scan();
        SceneView.lastActiveSceneView.Repaint();
    }

    protected override IEnumerable<object> GetTargets() {
        return new List<object>() { this, PathfindingSettings.Instance };
    }

    protected void Update() {
        SceneView.duringSceneGui -= OnSceneGUI;
        SceneView.duringSceneGui -= OnSceneGUI;
        SceneView.duringSceneGui += OnSceneGUI;
    }

    protected bool m_isDragging = false;
    protected PathfindingNode m_toDrag = null;

    int hash = "PathfindingEditor".GetHashCode();

    protected Vector2 m_mousePos = Vector2.zero;
    protected void OnSceneGUI(SceneView view) {
        int ID = GUIUtility.GetControlID(hash, FocusType.Passive);

        if (Active) {
            if (Event.current.type == EventType.MouseMove) { view.Repaint(); }

            m_mousePos = view.camera.ScreenToWorldPoint(GUIUtility.GUIToScreenPoint(Event.current.mousePosition));
            Ray mouseRay = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);

            List<PathfindingNode> inView = new List<PathfindingNode>();
            float drawDistanceSqr = PathfindingSettings.Instance.DrawDistance * PathfindingSettings.Instance.DrawDistance;
            foreach (PathfindingNode node in PathfindingGraph.Instance.Nodes) {
                if (node && (node.Point - view.camera.transform.position).sqrMagnitude < drawDistanceSqr) { inView.Add(node); }
            }

            PathfindingNode selectedNode = null;
            if (m_isDragging && m_toDrag) { selectedNode = m_toDrag; }
            else if (!Event.current.shift) {
                selectedNode = GeneralHelpers.GetLowestScoring(inView, (PathfindingNode node) => {
                    Vector3 flat = node.transform.position - mouseRay.origin;
                    flat -= Vector3.Project(flat, mouseRay.direction);
                    float dif = flat.magnitude;
                    return dif < PathfindingSettings.Instance.SelectionDistance ? flat.magnitude : float.MaxValue;
                });
            }

            bool mouseClicked = Event.current.type == EventType.MouseDown && Event.current.button == 0;
            bool mouseUp = Event.current.type == EventType.MouseUp && Event.current.button == 0;

            if (Event.current.shift) {
                if (Physics.Raycast(mouseRay, out RaycastHit hit, 200.0f, PathfindingSettings.Instance.EnvironmentMask)) {
                    if (mouseClicked) {
                        PathfindingNode node = (PrefabUtility.InstantiatePrefab(PathfindingSettings.Instance.NodePrefab, hit.transform) as GameObject).GetComponent<PathfindingNode>();
                        node.transform.position = hit.point;
                        node.transform.rotation = Quaternion.LookRotation(hit.normal);
                        PathfindingGraph.Instance.Nodes.Add(node);
                        PathfindingGraph.Instance.Scan();
                        view.Repaint();
                    }
                    else {
                        DrawFakeNode(view, inView, hit.point, hit.normal, Color.green);
                    }
                }
            }
            else if (Event.current.control) {
                if (selectedNode) {
                    inView.Remove(selectedNode);
                    if (mouseClicked) {
                        PathfindingGraph.Instance.Nodes.Remove(selectedNode);
                        DestroyImmediate(selectedNode.gameObject);
                        PathfindingGraph.Instance.Scan();
                        view.Repaint();
                    }
                    else {
                        DrawSpecificNode(view, selectedNode, Color.red);
                    }
                }
            }
            else if (!m_toDrag) {
                if (mouseClicked && selectedNode) {
                    m_isDragging = true;
                    m_toDrag = selectedNode;
                }
            }
            else if (m_toDrag) {
                if (Physics.Raycast(mouseRay, out RaycastHit hit, 200.0f, PathfindingSettings.Instance.EnvironmentMask)) {
                    m_toDrag.transform.parent = hit.transform;
                    m_toDrag.transform.position = hit.point;
                    m_toDrag.transform.rotation = Quaternion.LookRotation(hit.normal);
                    PathfindingGraph.Instance.Scan();
                }
            }

            if (mouseUp) {
                m_toDrag = null;
                m_isDragging = false;
            }
            else if (mouseClicked) {
                GUIUtility.hotControl = ID;
                Event.current.Use();
            }

            DrawNodes(view, inView);

            if (selectedNode) {
                Handles.color = Color.yellow;
                Handles.DrawWireDisc(selectedNode.Point, -view.camera.transform.forward, PathfindingSettings.Instance.NodeDrawSize * 1.25f);
                Handles.DrawLine(selectedNode.Point, mouseRay.origin);
            }
        }
    }

    protected void DrawNodes(SceneView view, List<PathfindingNode> inView) {
        Handles.color = PathfindingSettings.Instance.NodeColour;

        Vector3 discNormal = -view.camera.transform.forward;

        List<Vector3> connectionPoints = new List<Vector3>();
        List<Vector3> nodePoints = new List<Vector3>();
        foreach (PathfindingNode node in inView) {
            Handles.DrawSolidDisc(node.Point, discNormal, PathfindingSettings.Instance.NodeDrawSize);
            nodePoints.Add(node.transform.position);
            nodePoints.Add(node.Point);
            foreach (PathfindingNode.Connection connection in node.Connections) {
                connectionPoints.Add(connection.Owner.Point);
                connectionPoints.Add(connection.ConnectedTo.Point);
            }
        }

        Handles.DrawLines(nodePoints.ToArray());
        Handles.color = PathfindingSettings.Instance.ConnectionColour;
        Handles.DrawDottedLines(connectionPoints.ToArray(), PathfindingSettings.Instance.ConnectionSize);
    }

    protected void DrawSpecificNode(SceneView view, PathfindingNode node, Color colour) {
        Handles.color = colour;

        Vector3 discNormal = -view.camera.transform.forward;
        List<Vector3> nodePoints = new List<Vector3>();

        Handles.DrawSolidDisc(node.Point, discNormal, PathfindingSettings.Instance.NodeDrawSize);
        nodePoints.Add(node.transform.position);
        nodePoints.Add(node.Point);
        foreach (PathfindingNode.Connection connection in node.Connections) {
            nodePoints.Add(connection.Owner.Point);
            nodePoints.Add(connection.ConnectedTo.Point);
        }

        Handles.DrawDottedLines(nodePoints.ToArray(), PathfindingSettings.Instance.ConnectionSize);
    }

    protected void DrawFakeNode(SceneView view, List<PathfindingNode> inView, Vector3 rootPosition, Vector3 normal, Color colour) {
        Handles.color = colour;

        Vector3 discNormal = -view.camera.transform.forward;
        List<Vector3> nodePoints = new List<Vector3>();

        Vector3 point = rootPosition + normal * PathfindingSettings.Instance.NodeHeight;
        Handles.DrawSolidDisc(point, discNormal, PathfindingSettings.Instance.NodeDrawSize);
        nodePoints.Add(rootPosition);
        nodePoints.Add(point);

        foreach (PathfindingNode node in inView) {
            if (node.CanConnectWith(rootPosition, normal)) {
                nodePoints.Add(point);
                nodePoints.Add(node.Point);
            }
        }

        Handles.DrawDottedLines(nodePoints.ToArray(), PathfindingSettings.Instance.ConnectionSize);
    }
}
