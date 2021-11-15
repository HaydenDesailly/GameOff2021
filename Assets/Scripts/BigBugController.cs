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

    [SerializeField]
    private BigBugLegController[] _legs;

    private float _life;

    private void Awake()
    {
        if (BigBugManager.Instance.Nodes.Count > 0)
        {
            var spawnLocation = Random.Range(0, BigBugManager.Instance.Nodes.Count);
            targetNode = BigBugManager.Instance.Nodes[spawnLocation];
            transform.position = targetNode.Point;
        }
    }

    private void Start()
    {
        if (_legs == null || _legs.Length == 0)
        {
            Debug.LogWarning("Connect all the legs to the big bug animation sequencer!");
        }
        else
        {
            //kick off the leg animation sequencing by starting the 1st leg in the array
            _legs[0].Animator.SetTrigger("move");
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
            //attempt to kill player
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
                    
                }

                //turn towards next nav node
                transform.rotation = Quaternion.RotateTowards(transform.rotation, Quaternion.LookRotation(targetNode.Point - transform.position, targetNode.Normal), 270f * Time.deltaTime);
            }

            //leg animation sequencing
            bool triggerHit = false;
            int i;
            for (i = 0; i < _legs.Length; i++)
            {
                if (_legs[i].TriggerHit)
                {
                    triggerHit = true;
                    break;
                }
            }
            if (triggerHit)
            {
                _legs[i].TriggerHit = false;
                _legs[(i + 1) % _legs.Length].Animator.SetTrigger("move");
            }
        }
    }

    public void Kill()
    {
        if (!Dead)
        {
            Dead = true;

            foreach (var leg in _legs)
            {
                leg.Animator.SetBool("dead", true);
            }

            //simulating 1.5 second death animation
            var meshRenderer = GetComponent<MeshRenderer>();
            meshRenderer.material = _deadMaterial;
            Destroy(gameObject, 3f);
        }
    }
}
