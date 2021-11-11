using UnityEngine;

public class BigBugController : MonoBehaviour
{
    [SerializeField]
    private float _speed;

    BigBugManager.Node targetNode = null;

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

    private void FixedUpdate()
    {
        if (targetNode != null)
        {
            foreach (var child in targetNode.Children)
            {
                Debug.DrawLine(transform.position, child.Point, Color.red, 0.025f);
            }
        }
    }
}
