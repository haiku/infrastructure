# Reseeding initial-packages
Steps to upgrade the target packages to build against. This uses a local
bootstrap to avoid hairpin NAT complications. The x86_64 arch is used here,
substitute as needed.

## Run full bootstrap locally
```
mkdir reseed
cd reseed
sudo docker run --rm -v $PWD:/var/buildmaster haikuports/buildmaster \
	bootstrap --jobs 4 x86_64
```

## Copy initial-packages to server
```
scp -r -P 2222 haikuports/buildmaster/initial-packages \
	limerick.ams3.haiku-os.org:
```

## Run temporary container with volumes connected
```
sudo docker run -it --rm -v $PWD/initial-packages:/var/initial-packages-new:ro \
	-v ci_sources:/var/sources:ro -v ci_packages:/var/packages:ro \
	-v ci_data_master_x86_64:/var/buildmaster haikuports/buildmaster bash
```

## Sanity check repository consistency with new packages
```
cd /var/buildmaster/haikuports
. buildmaster/config
/var/sources/haikuporter/haikuporter --debug --check-repository-consistency \
	--no-package-obsoletion --system-packages-directory \
	/var/initial-packages-new
```

## Swap packages
```
cd /var/buildmaster/haikuports/buildmaster
mv initial-packages initial-packages-old
cp -r /var/initial-packages-new initial-packages
```

## Clean up local bootstrap
```
cd ..
sudo rm -r reseed
```
