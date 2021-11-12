using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class GeneralHelpers {
    /// <summary>
    /// Have the score method return float.MaxValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetLowestScoring<T>(List<T> contestants, System.Func<T, float> scoreMethod) {
        float winningScore = float.MaxValue * 0.5f;
        T winner = default(T);
        foreach (T t in contestants) {
            float score = scoreMethod(t);
            if (score < winningScore) {
                winningScore = score;
                winner = t;
            }
        }
        return winner;
    }

    /// <summary>
    /// Have the score method return float.MaxValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetLowestScoring<T>(T[] contestants, System.Func<T, float> scoreMethod) { return GetLowestScoring(contestants.ToList(), scoreMethod); }

    /// <summary>
    /// Have the score method return float.MinValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetHighestScoring<T>(List<T> contestants, System.Func<T, float> scoreMethod) {
        float winningScore = float.MinValue * 0.5f;
        T winner = default(T);
        foreach (T t in contestants) {
            float score = scoreMethod(t);
            if (score > winningScore) {
                winningScore = score;
                winner = t;
            }
        }
        return winner;
    }

    /// <summary>
    /// Have the score method return float.MinValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetHighestScoring<T>(T[] contestants, System.Func<T, float> scoreMethod) { return GetHighestScoring(contestants.ToList(), scoreMethod); }

    /// <summary>
    /// Have the score method return float.MaxValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetLowestScoring<T>(List<T> contestants, System.Func<T, int> scoreMethod) {
        float winningScore = int.MaxValue / 2;
        T winner = default(T);
        foreach (T t in contestants) {
            int score = scoreMethod(t);
            if (score < winningScore) {
                winningScore = score;
                winner = t;
            }
        }
        return winner;
    }

    /// <summary>
    /// Have the score method return float.MaxValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetLowestScoring<T>(T[] contestants, System.Func<T, int> scoreMethod) { return GetLowestScoring(contestants.ToList(), scoreMethod); }

    /// <summary>
    /// Have the score method return float.MinValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetHighestScoring<T>(List<T> contestants, System.Func<T, int> scoreMethod) {
        float winningScore = int.MinValue / 2;
        T winner = default(T);
        foreach (T t in contestants) {
            int score = scoreMethod(t);
            if (score > winningScore) {
                winningScore = score;
                winner = t;
            }
        }
        return winner;
    }

    /// <summary>
    /// Have the score method return float.MinValue if you want the entry to be skipped entirely
    /// </summary>
    public static T GetHighestScoring<T>(T[] contestants, System.Func<T, int> scoreMethod) { return GetHighestScoring(contestants.ToList(), scoreMethod); }

}
