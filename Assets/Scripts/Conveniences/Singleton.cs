using UnityEngine;

public class Singleton<T> : MonoBehaviour where T : Singleton<T>
{
    static T s_instance;
    public static T Instance {
        get {
            if (!s_instance) { s_instance = FindObjectOfType<T>(); }
            return s_instance;
        }
        protected set { s_instance = value; }
    }

    protected virtual void Awake() {
        if (!s_instance) { Instance = this as T; }
        else {
            Debug.LogError("Oops, multiple singletons of type: " + typeof(T).ToString() + ", destroying");
            Destroy(gameObject);
        }
    }
}
