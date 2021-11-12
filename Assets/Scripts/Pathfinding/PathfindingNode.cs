using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathfindingNode : MonoBehaviour {
    public Vector3 Normal => transform.forward;
    public Vector3 Point => transform.position + Normal * PathfindingSettings.Instance.NodeHeight;

    [System.Serializable]
    public class Connection {
        public Connection(PathfindingNode owner, PathfindingNode connectedTo, float cost) {
            Owner = owner;
            ConnectedTo = connectedTo;
            Cost = cost;
        }
        public PathfindingNode Owner;
        public PathfindingNode ConnectedTo;
        public float Cost;
    }
    public List<Connection> Connections = new List<Connection>();

    public void Connect(PathfindingNode other, float cost) {
        Connections.Add(new Connection(this, other, cost));
        other.Connections.Add(new Connection(other, this, cost));
    }

    public Connection GetConnectionWith(PathfindingNode other) {
        foreach (Connection connection in Connections) {
            if (connection.ConnectedTo == other) { return connection; }
        }
        return null;
    }

    public void ResetEntirely() {
        Connections = new List<Connection>();
    }

    public bool HasConnectionWith(PathfindingNode other) => GetConnectionWith(other) != null;

    public void TryConnect(PathfindingNode other) {
        if (other != this && !HasConnectionWith(other)) {
            Vector3 point = Point;
            Vector3 dif = other.Point - point;
            float difMag = dif.sqrMagnitude;
            if (difMag <= PathfindingSettings.Instance.MaxConnectionDistanceSqr) {
                difMag = Mathf.Sqrt(difMag);
                Ray obscuranceRay = new Ray(Point, dif);
                if (!Physics.Raycast(obscuranceRay, difMag, PathfindingSettings.Instance.EnvironmentMask)) {
                    float stepLength = 1.0f / (PathfindingSettings.Instance.FootCheckSteps + 1);
                    float step = stepLength;
                    Ray footCheckRay;
                    for (int i = 0; i < PathfindingSettings.Instance.FootCheckSteps; ++i) {
                        footCheckRay = new Ray(point + dif * step, -Vector3.Lerp(Normal, other.Normal, step));
                        if (!Physics.Raycast(footCheckRay, PathfindingSettings.Instance.FootCheckDepth, PathfindingSettings.Instance.EnvironmentMask)) {
                            // There's a gap between these two nodes
                            return;
                        }
                        step += stepLength;
                    }

                    // Connection is valid
                    Connect(other, difMag);
                }
            }
        }
    }

    public bool CanConnectWith(Vector3 nodePosition, Vector3 nodeNormal) {
        Vector3 point = Point;
        Vector3 otherPoint = nodePosition + nodeNormal * PathfindingSettings.Instance.NodeHeight;
        Vector3 dif = otherPoint - point;
        float difMag = dif.sqrMagnitude;
        if (difMag <= PathfindingSettings.Instance.MaxConnectionDistanceSqr) {
            difMag = Mathf.Sqrt(difMag);
            Ray obscuranceRay = new Ray(Point, dif);
            if (!Physics.Raycast(obscuranceRay, difMag, PathfindingSettings.Instance.EnvironmentMask)) {
                float stepLength = 1.0f / (PathfindingSettings.Instance.FootCheckSteps + 1);
                float step = stepLength;
                Ray footCheckRay;
                for (int i = 0; i < PathfindingSettings.Instance.FootCheckSteps; ++i) {
                    footCheckRay = new Ray(point + dif * step, -Vector3.Lerp(Normal, nodeNormal, step));
                    if (!Physics.Raycast(footCheckRay, PathfindingSettings.Instance.FootCheckDepth, PathfindingSettings.Instance.EnvironmentMask)) {
                        // There's a gap between these two nodes
                        return false;
                    }
                    step += stepLength;
                }

                // Connection is valid
                return true;
            }
        }

        return false;
    }
}