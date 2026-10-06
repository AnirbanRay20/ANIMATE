import numpy as np


def floyd_warshall(adjacency_matrix):
    """
    Compute all-pairs shortest paths using Floyd-Warshall.

    Compatible replacement for the original Cython implementation
    used by ANIMATE.
    """

    nrows, ncols = adjacency_matrix.shape
    assert nrows == ncols

    # Match original Cython behavior:
    # convert adjacency matrix to int64
    M = adjacency_matrix.astype(np.int64, order="C", copy=True)

    # Path reconstruction matrix
    path = -1 * np.ones((nrows, ncols), dtype=np.int64)

    # Set diagonal to zero and unreachable edges to 510
    for i in range(nrows):
        for j in range(ncols):
            if i == j:
                M[i, j] = 0
            elif M[i, j] == 0:
                M[i, j] = 510

    # Floyd-Warshall
    for k in range(nrows):
        for i in range(nrows):
            for j in range(nrows):
                cost = M[i, k] + M[k, j]

                if M[i, j] > cost:
                    M[i, j] = cost
                    path[i, j] = k

    # Mark unreachable nodes
    for i in range(nrows):
        for j in range(ncols):
            if M[i, j] >= 510:
                path[i, j] = 510
                M[i, j] = 510

    return M, path


def get_all_edges(path, i, j):
    """Recursively reconstruct intermediate nodes."""

    k = int(path[i, j])

    if k == -1:
        return []

    return (
        get_all_edges(path, i, k)
        + [k]
        + get_all_edges(path, k, j)
    )


def gen_edge_input(max_dist, path, edge_feat):
    """
    Generate edge features along shortest paths.

    Kept for compatibility with the original ANIMATE implementation.
    """

    nrows, ncols = path.shape
    assert nrows == ncols

    path_copy = path.astype(np.int64, order="C", copy=True)
    edge_feat_copy = edge_feat.astype(np.int64, order="C", copy=True)

    edge_fea_all = -1 * np.ones(
        (
            nrows,
            ncols,
            max_dist,
            edge_feat.shape[-1],
        ),
        dtype=np.int64,
    )

    for i in range(nrows):
        for j in range(ncols):

            if i == j:
                continue

            if path_copy[i, j] == 510:
                continue

            node_path = (
                [i]
                + get_all_edges(path_copy, i, j)
                + [j]
            )

            num_path = len(node_path) - 1

            for k in range(num_path):
                edge_fea_all[
                    i, j, k, :
                ] = edge_feat_copy[
                    node_path[k],
                    node_path[k + 1],
                    :
                ]

    return edge_fea_all