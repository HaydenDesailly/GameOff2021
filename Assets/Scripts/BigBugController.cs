using UnityEngine;

public class BigBugController : MonoBehaviour
{
    [SerializeField]
    private float _speed = 10f;

    BigBugManager.Node targetNode = null;

    [HideInInspector]
    public bool Dead;

    [SerializeField]
    private Material _deadMaterial;

    [SerializeField]
    private float _lifeSpan = 30f;

    private float _life;

    private void Start()
    {
        if (BigBugManager.Instance.Nodes.Count > 0)
        {
            var spawnLocation = Random.Range(0, BigBugManager.Instance.Nodes.Count);
            targetNode = BigBugManager.Instance.Nodes[spawnLocation];
            transform.position = targetNode.Point;
            transform.rotation = Quaternion.FromToRotation(targetNode.Point, targetNode.Normal);
        }
    }

    private void Update()
    {
        _life += Time.deltaTime;
        if (_life > _lifeSpan)
        {
            Dead = true;
            Destroy(gameObject);
        }

        if (!Dead)
        {
            var playerPosition = PlayerManager.Instance.Player.transform.position;

            if (targetNode != null)
            {
                if (Vector3.Distance(transform.position, targetNode.Point) > 0.1f)
                {
                    //keep heading towards targetNode
                    transform.position += (targetNode.Point - transform.position).normalized * Time.deltaTime * _speed;
                }
                else
                {
                    //find next targetNode in player direction
                    var nextNode = targetNode;
                    foreach (var node in targetNode.Children)
                    {
                        if (Vector3.Distance(node.Point, playerPosition) < Vector3.Distance(transform.position, playerPosition))
                        {
                            nextNode = node;
                            break;
                        }
                    }

                    targetNode = nextNode;
                    transform.rotation = Quaternion.FromToRotation(targetNode.Point, targetNode.Normal);
                }
            }
        }
    }

    public void Kill()
    {
        if (!Dead)
        {
            Dead = true;

            //todo 
            // catch fire
            // shrivle up
            // die

            //simulating 1.5 second death animation
            var meshRenderer = GetComponent<MeshRenderer>();
            meshRenderer.material = _deadMaterial;
            Destroy(gameObject, 1.5f);
        }
    }
}
