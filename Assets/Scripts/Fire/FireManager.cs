using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireManager : Singleton<FireManager>
{
    public GameObject FirePrefab;
    public LayerMask PlacementMask;
    public int FirePlacementRefinements = 3;
    [OnValueChanged("ValuesChanged")] public float FireRadius = 1.0f;
    [OnValueChanged("ValuesChanged")] public float MinimumDistanceAway = 0.2f;
    public float Overlap = 0.5f;
    public float MaximumRefinementDistance = 1.2f;

    protected float m_fireRadiusSqr;
    protected float m_minDistDqr;

    void ValuesChanged() {
        m_fireRadiusSqr = FireRadius * FireRadius;
        m_minDistDqr = MinimumDistanceAway * MinimumDistanceAway;
    }

    protected override void Awake() {
        base.Awake();
        ValuesChanged();
    }

    protected List<Fire> m_fires = new List<Fire>();

    public void AttemptFirePlacement(RaycastHit hit) => AttemptFirePlacement(hit.point, hit.normal);
    public void AttemptFirePlacement(Vector3 point, Vector3 normal) {
        float refinementDistance = 0.0f;
        for (int i = 0; i < FirePlacementRefinements; ++i) {
            if (!RefinePlacement(ref point, ref normal, ref refinementDistance)) { return; } // Failed to place
        }

        Fire fire = Instantiate(FirePrefab, point, Quaternion.LookRotation(-normal)).GetComponent<Fire>();
        fire.onDeath += () => { m_fires.Remove(fire); };
        m_fires.Add(fire);
    }

    protected bool RefinePlacement(ref Vector3 placement, ref Vector3 normal, ref float refinementDistance) {
        foreach (Fire fire in m_fires) {
            Vector3 dif = placement - fire.transform.position;
            float mag = dif.sqrMagnitude;
            if (mag < m_minDistDqr) {
                fire.Extend();
                return false;
            }
            else if (mag < m_fireRadiusSqr) {
                mag = Mathf.Sqrt(mag);
                dif /= mag;
                Vector3 previousPlacement = placement;
                placement += dif * (Overlap - mag);
                if (Physics.Raycast(new Ray(placement + normal * Overlap, -normal), out RaycastHit hit, Overlap + 2.0f, PlacementMask)) {
                    placement = hit.point;
                    normal = hit.normal;
                }

                refinementDistance += (placement - previousPlacement).magnitude;
                if (refinementDistance >= MaximumRefinementDistance) { return false; }
            }
        }

        return true;
    }
}
