using UnityEngine;

public class BigBugLegController : MonoBehaviour
{
    [HideInInspector]
    public Animator Animator;

    [HideInInspector]
    public bool TriggerHit;

    public void Trigger()
    {
        TriggerHit = true;
    }

    private void Awake()
    {
        Animator = GetComponent<Animator>();
    }
}
