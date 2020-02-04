import random

from Picker import Picker
from Jnode import Jnode, DirNode, FileNode, SymlinkNode

from sklearn.cluster import KMeans
import numpy as np

import config


class KmeansPicker(Picker):
    def __init__(self):
        super().__init__()
        self.picked_nodes_ = []
        self.num_to_pick_ = config.get('KMEANS_CLUSTER')
        self.which_to_pick_ = [Jnode.FILE]

    def _pick(self, tree, node_types):
        self.which_to_pick_ = node_types
        self.picked_nodes_ = []
        self.num_to_pick_ = config.get('KMEANS_CLUSTER')

        self._visit(tree.working_root_)

        if not self.picked_nodes_:
            return []
        elif len(self.picked_nodes_) < self.num_to_pick_:
            return self.picked_nodes_
        else:
            return self._kmeans_pick()

    def _kmeans_pick(self):
        km = KMeans(n_clusters=self.num_to_pick_)
        data = np.array([nd.get_vec() for nd in self.picked_nodes_], np.int32)
        km.fit(data)

        cluster_labels = set(km.labels_)

        node_idx_label = list(enumerate(km.labels_))
        random.shuffle(node_idx_label)
        picked = []

        #
        # Randomly pick a node as representative with cluster label
        # (We have shuffled the list)
        #
        for cluster_label in cluster_labels:
            for (idx, label) in node_idx_label:
                if label == cluster_label:
                    picked.append(self.picked_nodes_[idx])
                    break

        assert len(picked) == len(cluster_labels)
        return picked

    def _visit_dir(self, node):
        if Jnode.DIR in self.which_to_pick_:
            self.picked_nodes_.append(node)

        for child in node:
            self._visit(child)

    def _visit_file(self, node):
        if Jnode.FILE in self.which_to_pick_:
            self.picked_nodes_.append(node)

    def _visit_symlink(self, node):
        if Jnode.SYMLINK in self.which_to_pick_:
            self.picked_nodes_.append(node)
