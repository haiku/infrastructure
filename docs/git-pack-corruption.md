# Git Pack Corruption

Here follows a tale of woe, loathing, and redemption.

## Issue

Users begin noticing errors in cgit + gerrit.

A git fsck run on our bare repository identified a corrupted .pack:

```
[root@maui haiku.git]# git fsck
Checking object directories: 100% (256/256), done.
error: ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack SHA1 checksum mismatch
error: index CRC mismatch for object fc958868b43e84ad97ff18b869a2a189e868043d from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack at offset 2412307
error: inflate: data stream error (incorrect data check)
error: cannot unpack fc958868b43e84ad97ff18b869a2a189e868043d from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack at offset 2412307
error: index CRC mismatch for object 3c4005459044276d5d0a672078f5aad786a10491 from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack at offset 71508637
error: inflate: data stream error (incorrect data check)
error: cannot unpack 3c4005459044276d5d0a672078f5aad786a10491 from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack at offset 71508637
error: index CRC mismatch for object 5076a0f6a11bfe3b73f57549c5248791dfce8bf6 from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack at offset 76604000
error: inflate: data stream error (incorrect data check)
error: cannot unpack 5076a0f6a11bfe3b73f57549c5248791dfce8bf6 from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack at offset 76604000
Checking objects: 100% (674628/674628), done.
error: inflate: data stream error (incorrect data check)
error: failed to read object fc958868b43e84ad97ff18b869a2a189e868043d at offset 2412307 from ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack
fatal: packed object fc958868b43e84ad97ff18b869a2a189e868043d (stored in ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack) is corrupt
```


## Resolution

Move the repository to a position out of the line of fire.
```mv haiku.git haiku.git-corrupt```

To resolve the problem, move the corrupted .pack to a safe location:

```
mkdir ~/git-recovery; mv ./objects/pack/pack-5d07d62e655a96254f20d257e96bea81469a1089.pack ~/git-recovery/
```

Re-run fsck:
```
[root@maui haiku.git-corrupt]# git fsck
Checking object directories: 100% (256/256), done.
Checking objects: 100% (2830/2830), done.
error: refs/tags/hrev39694 does not point to a valid object!
broken link from    tree 02fbd54a7521e0aa78c61400df06d2c722423753
              to    blob 5076a0f6a11bfe3b73f57549c5248791dfce8bf6
broken link from    tree 38a1286f370eb866d75b069089e7f3949373b4e5
              to    blob 3c4005459044276d5d0a672078f5aad786a10491
broken link from  commit 1691b94fe3050ed66beb25b4c192852da2373270
              to  commit fc958868b43e84ad97ff18b869a2a189e868043d
Checking connectivity: 673746, done.
missing blob 5076a0f6a11bfe3b73f57549c5248791dfce8bf6
dangling commit 413f42a66f0d3d649a23c9abaa127d9f1bb17c8a
dangling tree 5ff762f983aad4c218a73f95749c5e5f43ab006e
dangling commit 10f94414938daa527e43205ebd86e1ea3eff8c1e
missing blob 3c4005459044276d5d0a672078f5aad786a10491
dangling commit e78ac6f88f83d959d0da975afd15dd9e92d01f17
missing commit fc958868b43e84ad97ff18b869a2a189e868043d
dangling commit 086dacb0b8f77794abaddbcd0aaf2278a01af7f4
dangling tree f3d3ae9c9f77bc08f6825a83ccc80eb25d0e1c09
dangling commit d26af6ddf258353292e15ddc4d9acd17bdcd94aa
dangling commit 8d53f7e0718c2919ec72d6224db0c4956b95fd1d
dangling commit c0085d9605abceec19754bc9a69b6d6cb08ee228
```

At this stage, the priority is recovering the "missing XXX" objects
from a healthy repo.


**Blob:**

Healthy repo: ```git show 5076a0f6a11bfe3b73f57549c5248791dfce8bf6 > 5076a0f6```

Corrupt repo: ```git hash-object -w ~/5076a0f6```


**Commit:**

Healthy repo: ```git cat-file commit fc958868b43e84ad97ff18b869a2a189e868043d > fc958868```

Corrupt repo: ```git hash-object -t commit -w ~/fc958868```



Once all missing objects are resolved, save the dangling objects:
```
git fsck --lost-found
```

One final ```git fsck``` ensuring all "_missing XXX and broken link_" messages are gone.

```git gc``` to cleanup the final danglging objects.
