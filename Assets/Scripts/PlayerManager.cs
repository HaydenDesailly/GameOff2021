using UnityEngine;

public class PlayerManager : MonoBehaviour
{
    public static PlayerManager Instance
    {
        get { return _instance ??= FindObjectOfType<PlayerManager>() ?? new PlayerManager { }; }
    }
    private static PlayerManager _instance;

    public GameObject Player { get; private set; }

    private void Awake()
    {
        Player = FindObjectOfType<PlayerMovement>().gameObject;
    }
}
