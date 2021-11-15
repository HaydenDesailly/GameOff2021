using UnityEngine;

public class PlayerManager : Singleton<PlayerManager>
{
    public GameObject Player { get; private set; }

    protected override void Awake()
    {
        Player = GameObject.FindGameObjectWithTag("Player");
    }
}
