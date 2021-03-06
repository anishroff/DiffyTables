import Foundation

//
// Diffing code
//

/// Calculates the longest common subsequence of two arrays
/// Based on http://rosettacode.org/wiki/Longest_common_subsequence

func logestCommonSubsequence<T: Equatable>(s1: [T], s2: [T]) -> [T] {
    var x = s1.count
    var y = s2.count
    var lens = Array(count: x + 1, repeatedValue: Array(count: y + 1, repeatedValue: 0))
    var result: [T] = []
    
    for i in 0..<x {
        for j in 0..<y {
            if s1[i] == s2[j] {
                lens[i + 1][j + 1] = lens[i][j] + 1
            } else {
                lens[i + 1][j + 1] = max(lens[i + 1][j], lens[i][j + 1])
            }
        }
    }
    
    while x != 0 && y != 0 {
        if lens[x][y] == lens[x - 1][y] {
            --x
        } else if lens[x][y] == lens[x][y - 1] {
            --y
        } else {
            result.append(s1[x - 1])
            --x
            --y
        }
    }
    
    return result.reverse()
}

public enum AlignmentDiffChange {
    case Insertion(pos: Int, len: Int)
    case Deletion(pos: Int, len: Int)
}

/// Calculates the smallest possible set of insertions and deletions
/// to align as many elements in `left` with elements in `right` as possible.
/// This makes substitutions in the next step more efficient.
///
/// This method works by calculating distances between common elements
/// in `left` and `right`. If the distances differ, deletions and insertions
/// are added to align the common elements.

public func diffToAlign<T: Equatable>(left: [T], right: [T]) -> [AlignmentDiffChange] {
    let lcs = logestCommonSubsequence(left, right)
    
    var left_i = 0
    var right_i = 0
    
    var totalOffset = 0
    
    var changes: [AlignmentDiffChange] = []
    
    for commonElement in lcs {
        var leftOffset = 0
        var rightOffset = 0
        
        // find index of el in left
        while true {
            if left[left_i] == commonElement {
                break
            } else {
                left_i++
                leftOffset++
            }
        }
        
        // find index of el in right
        while true {
            if right[right_i] == commonElement {
                break
            } else {
                right_i++
                rightOffset++
            }
        }
        
        // if offsets differ, add to list of changes
        if rightOffset > leftOffset {
            let insertions = rightOffset - leftOffset
            let pos = left_i + totalOffset
            changes.append(.Insertion(pos: pos, len: insertions))
            totalOffset += insertions
        } else if leftOffset > rightOffset {
            let deletions = leftOffset - rightOffset
            let pos = left_i - deletions + totalOffset
            changes.append(.Deletion(pos: pos, len: deletions))
            totalOffset -= deletions
        }
    }
    
    // elements after last common element
    var afterLastInLeft = left.count - left_i - 1
    var afterLastInRight = right.count - right_i - 1
    
    if afterLastInRight > afterLastInLeft {
        let insertions = afterLastInRight - afterLastInLeft
        let pos = left_i + 1 + totalOffset
        changes.append(.Insertion(pos: pos, len: insertions))
    } else if afterLastInLeft > afterLastInRight {
        let deletions = afterLastInLeft - afterLastInRight
        let pos = left_i + 1 + totalOffset
        changes.append(.Deletion(pos: pos, len: deletions))
    }
    
    return changes
}