using UnityEngine;

public class PlayerManager : Singleton<PlayerManager>
{
    public GameObject Player { get; private set; }

    protected override void Awake()
    {
        base.Awake();

        Player = GameObject.FindGameObjectWithTag("Player");
    }
}
