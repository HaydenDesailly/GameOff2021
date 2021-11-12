using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "PathfindingSettings", menuName = "Game Jam/Pathfinding Settings")]
public class PathfindingSettings : ResourceSingleton<PathfindingSettings> {
    [InfoBox("There is no root object with this name in the game scene!", "ContainerCheck", InfoMessageType = InfoMessageType.Error)]
    public string EnvironmentContainerName = "Environment";
    public Transform EnvironmentContainer {
        get {
            foreach (var obj in UnityEngine.SceneManagement.SceneManager.GetActiveScene().GetRootGameObjects()) {
                if (obj.name == EnvironmentContainerName) { return obj.transform; }
            }
            return null;
        }
    }

    protected bool ContainerCheck => EnvironmentContainer == null;

    public GameObject NodePrefab;

    [Header("Node Properties")]
    public float NodeHeight = 0.5f;
    public float MaxConnectionDistance = 5.0f;
    public float MaxConnectionDistanceSqr => MaxConnectionDistance * MaxConnectionDistance;
    public int FootCheckSteps = 4;
    public float FootCheckDepth = 0.75f;
    public LayerMask EnvironmentMask;

    [Header("Draw Settings")]
    public float DrawDistance = 50.0f;
    public float SelectionDistance = 5.0f;
    public float NodeDrawSize = 0.2f;
    public Color NodeColour;
    public Color ConnectionColour;
    public float ConnectionSize = 0.5f;
}