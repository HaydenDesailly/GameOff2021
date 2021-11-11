using UnityEngine;

public class FlamethrowerProjectile : MonoBehaviour
{
    public float StartingGravity = -9.8f;
    public float EndingGravity = -2.0f;
    public float GravityTransitionTime = 0.8f;
    [Range(0.0f, 1.0f)] public float Drag = 0.05f;
    public float LifeTime = 2.0f;

    protected float CurrentGravity => Mathf.Lerp(StartingGravity, EndingGravity, m_lifeTimer / GravityTransitionTime);

    public ParticleSystem Emission;
    public Vector2 EmissionSizeMin = new Vector2(0.02f, 0.08f);
    public Vector2 EmissionSizeMax = new Vector2(0.2f, 0.55f);
    public float EmissionTransitionDelay = 0.4f;
    public float EmissionTransitionTime = 0.4f;
    protected float EmissionT {
        get {
            float x = Mathf.Clamp01((m_lifeTimer - EmissionTransitionDelay) / EmissionTransitionTime);
            return x * x;
        }
    }

    protected float m_lifeTimer = 0.0f;
    protected Vector3 m_velocity;
    public void Initialize(Vector3 startingVelocity) {
        m_velocity = startingVelocity;
    }

    public void LateUpdate() {
        transform.position += m_velocity * Time.deltaTime;
        m_velocity += Vector3.down * CurrentGravity * Time.deltaTime;
        m_velocity *= 1.0f - Drag;

        if (m_lifeTimer >= EmissionTransitionDelay) {
            var main = Emission.main;
            Vector2 emissionSize = Vector2.Lerp(EmissionSizeMin, EmissionSizeMax, EmissionT);
            main.startSize = new ParticleSystem.MinMaxCurve(emissionSize.x, emissionSize.y);
        }

        m_lifeTimer += Time.deltaTime;
        if (m_lifeTimer >= LifeTime) { Destroy(gameObject); }
    }
}
