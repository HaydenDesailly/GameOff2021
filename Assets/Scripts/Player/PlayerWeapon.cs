using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerWeapon : Singleton<PlayerWeapon>
{
    [Header("Movement")]
    public Transform Weapon;
    public Vector3 HoldOffset = Vector3.zero;
    public float AimDistance = 50.0f;
    public float PositionalLerpStrength = 8.0f;
    public float RotationalLerpStrength = 12.0f;

    public float OffsetLerpStrength = 12.0f;
    public float OffsetDampStrength = 8.0f;
    public float VelocityOffsetMultiplier = 0.01f;

    protected Vector3 m_posOffset;
    protected Vector3 m_velOffset;
    protected Vector3 m_dirOffset;

    protected Vector3 m_currentPosition;
    protected Vector3 m_currentPosOffset;

    protected Rigidbody m_rb;

    [Header("Firing")]
    public KeyCode FireKey = KeyCode.Mouse0;
    public Transform FirePort;
    public GameObject Projectile;
    public float TriggerDelay = 0.08f;
    public float ChargeTime = 0.2f;
    public float MinVelocity = 4.0f;
    public float MaxVelocity = 22.0f;
    public float FireRate = 0.08f;

    protected float m_fireRateTimer = 0.0f;
    protected float m_chargeTimer = 0.0f;
    protected float m_triggerDelayTimer = 0.0f;

    protected float ChargeT => Mathf.Clamp01(m_chargeTimer / ChargeTime);

    public void Translate(Vector3 translation) {
        m_currentPosition += translation;
    }

    public void AddPositionOffset(Vector3 offset) {
        m_posOffset += offset;
    }

    protected override void Awake() {
        base.Awake();
        m_rb = GetComponent<Rigidbody>();
    }

    private void LateUpdate() {
        m_velOffset = -m_rb.velocity * VelocityOffsetMultiplier;

        Vector3 rootPosition = PlayerMovement.Instance.PlayerCamera.transform.position + PlayerMovement.Instance.PlayerCamera.transform.rotation * HoldOffset;

        // Rotation
        Weapon.rotation = Quaternion.Lerp(Weapon.rotation, Quaternion.LookRotation((PlayerMovement.Instance.PlayerCamera.transform.position + PlayerMovement.Instance.PlayerCamera.transform.forward * AimDistance) - rootPosition), Time.deltaTime * RotationalLerpStrength);

        // Position
        m_currentPosition = Vector3.Lerp(m_currentPosition, rootPosition, Time.deltaTime * PositionalLerpStrength);
        m_currentPosOffset = Vector3.Lerp(m_currentPosOffset, m_velOffset + m_posOffset, Time.deltaTime * OffsetLerpStrength);
        Weapon.position = m_currentPosition + m_currentPosOffset;

        m_posOffset = Vector3.Lerp(m_posOffset, Vector3.zero, Time.deltaTime * OffsetDampStrength);

        if (m_fireRateTimer < FireRate) { m_fireRateTimer += Time.deltaTime; }
        if (Input.GetKey(FireKey)) {
            m_triggerDelayTimer += Time.deltaTime;

            if (m_triggerDelayTimer >= TriggerDelay) {
                m_chargeTimer = Mathf.Min(m_chargeTimer + Time.deltaTime, ChargeTime);
                if (m_fireRateTimer >= FireRate) {
                    m_fireRateTimer -= FireRate;
                    Fire();
                }
            }
            else { m_chargeTimer = Mathf.Max(m_chargeTimer - Time.deltaTime, 0.0f); }
        }
        else {
            m_triggerDelayTimer = 0.0f;
            m_chargeTimer = Mathf.Max(m_chargeTimer - Time.deltaTime, 0.0f);
        }
    }

    protected void Fire() {
        Instantiate(Projectile, FirePort.position, FirePort.rotation).GetComponent<FlamethrowerProjectile>().Initialize(FirePort.forward * Mathf.Lerp(MinVelocity, MaxVelocity, ChargeT) + m_rb.velocity);
    }
}
