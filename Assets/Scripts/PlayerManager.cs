using UnityEngine;

public class PlayerManager : Singleton<PlayerManager>
{
    public GameObject Player { get; private set; }

    private void Awake()
    {
        Player = GameObject.FindGameObjectWithTag("Player");
    }
}
