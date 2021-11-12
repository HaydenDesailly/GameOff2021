using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathfindingGraph : Singleton<PathfindingGraph> {
    public List<PathfindingNode> Nodes = new List<PathfindingNode>();

    public void RefreshNodes() {
        Nodes = new List<PathfindingNode>(PathfindingSettings.Instance.EnvironmentContainer.GetComponentsInChildren<PathfindingNode>());
    }

    public void Scan() {
        foreach (PathfindingNode node in Nodes) { node.ResetEntirely(); }

        foreach (PathfindingNode n1 in Nodes) {
            foreach (PathfindingNode n2 in Nodes) { n1.TryConnect(n2); }
        }
    }
}