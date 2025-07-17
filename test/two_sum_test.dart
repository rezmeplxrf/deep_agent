// LeetCode Problem: Two Sum (Easy)
// Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.
// You may assume that each input would have exactly one solution, and you may not use the same element twice.

import 'package:test/test.dart';

class Solution {
  /// Time Complexity: O(n)
  /// Space Complexity: O(n)
  /// Uses HashMap for efficient lookup
  List<int> twoSum(List<int> nums, int target) {
    Map<int, int> numToIndex = {};
    
    for (int i = 0; i < nums.length; i++) {
      int complement = target - nums[i];
      
      if (numToIndex.containsKey(complement)) {
        return [numToIndex[complement]!, i];
      }
      
      numToIndex[nums[i]] = i;
    }
    
    return [];
  }
}

void main() {
  group('Two Sum Tests', () {
    final solution = Solution();
    
    test('Example 1: [2,7,11,15], target = 9', () {
      expect(solution.twoSum([2, 7, 11, 15], 9), equals([0, 1]));
    });
    
    test('Example 2: [3,2,4], target = 6', () {
      expect(solution.twoSum([3, 2, 4], 6), equals([1, 2]));
    });
    
    test('Example 3: [3,3], target = 6', () {
      expect(solution.twoSum([3, 3], 6), equals([0, 1]));
    });
    
    test('Edge case: negative numbers', () {
      expect(solution.twoSum([-1, -2, -3, -4, -5], -8), equals([2, 4]));
    });
    
    test('Edge case: zero in array', () {
      expect(solution.twoSum([0, 4, 3, 0], 0), equals([0, 3]));
    });
  });
}