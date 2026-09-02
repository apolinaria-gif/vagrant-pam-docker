Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.define "ubuntu_server" do |server|
    server.vm.provider "vmware_desktop" do |v|
      v.memory = 1024
      v.vmx["virtualHW.version"] = "19"
      
      # Создаем независимый SCSI-контроллер
      v.vmx["scsi1.present"] = "TRUE"
      v.vmx["scsi1.virtualDev"] = "lsilogic"

      # Указываем абсолютные пути к файлам внутри папки проекта через переменные Vagrant,
      # чтобы они создавались прямо в рабочей директории и никуда не пропадали
      proj_dir = File.dirname(__FILE__)
      
      v.vmx["scsi1:0.present"] = "TRUE"
      v.vmx["scsi1:0.filename"] = File.join(proj_dir, "disk1.vmdk").gsub("/", "\\\\")
      v.vmx["scsi1:0.mode"] = "persistent"
      v.vmx["scsi1:0.type"] = "disk"

      v.vmx["scsi1:1.present"] = "TRUE"
      v.vmx["scsi1:1.filename"] = File.join(proj_dir, "disk2.vmdk").gsub("/", "\\\\")
      v.vmx["scsi1:1.mode"] = "persistent"
      v.vmx["scsi1:1.type"] = "disk"
    end

    # Создаем пустые файлы дисков прямо средствами Ruby, если их нет
    # Это избавит нас от поиска утилит и ошибок путей в Windows
    [ "disk1.vmdk", "disk2.vmdk" ].each do |disk|
      disk_path = File.join(File.dirname(__FILE__), disk)
      unless File.exist?(disk_path)
        File.open(disk_path, "w") do |f|
          f.write("# Disk DescriptorFile\nversion=1\nCID=fffffffe\nparentCID=ffffffff\nonsnapshot=\"none\"\nsgscsi_vmx_compatible=\"buffered\"\ncreateType=\"monolithicFlat\"\n\n# Extent Description\nRW 2097152 FLAT \"#{disk.sub('.vmdk', '-flat.vmdk')}\" 0\n\n# The Disk Data Base\n#DDB\n\nddb.adapterType = \"lsilogic\"\nddb.geometry.sectors = \"63\"\nddb.geometry.heads = \"255\"\nddb.geometry.cylinders = \"130\"\nddb.virtualHWVersion = \"19\"\n")
        end
        # Создаем плоский файл данных размером 1 ГБ
        flat_path = disk_path.sub('.vmdk', '-flat.vmdk')
        File.write(flat_path, "\0" * (1024 * 1024 * 1024))
      end
    end

    server.vm.network "forwarded_port", guest: 80, host: 8080
    server.vm.provision "shell", path: "provision.sh"
  end
end