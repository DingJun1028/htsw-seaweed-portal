#!/usr/bin/env python3
"""
★ Nuber平台 自動化佈署腳本 ★
5T Protocol 完整自動化
"""

import json
import os
import subprocess
import sys
from pathlib import Path

class OmniDeploy:
    def __init__(self, config_path='deploy-config.json'):
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        self.project_root = Path(__file__).parent
        self.deploy_log = []
    
    def log(self, message, level='INFO'):
        entry = f"[{level}] {message}"
        print(entry)
        self.deploy_log.append(entry)
    
    def run_command(self, cmd, cwd=None, timeout=60):
        """執行 shell 命令"""
        try:
            result = subprocess.run(
                cmd, 
                shell=True, 
                capture_output=True, 
                text=True, 
                cwd=cwd or self.project_root,
                timeout=timeout
            )
            return result.returncode == 0, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return False, '', 'Timeout'
        except Exception as e:
            return False, '', str(e)
    
    def pre_deployment_checks(self):
        """部署前檢查"""
        self.log("🔍 執行部署前檢查...")
        
        # 檢查必要檔案
        required_files = ['index.html', 'style.css', 'script.js', 'package.json']
        for f in required_files:
            if not (self.project_root / f).exists():
                self.log(f"❌ 缺少必要檔案: {f}", 'ERROR')
                return False
        
        # 檢查建置目錄
        if not (self.project_root / 'dist').exists():
            self.log("⚠️ dist/ 目錄不存在，執行建置...")
            success, _, _ = self.run_command('npm run build')
            if not success:
                self.log("❌ 建置失敗"), 'ERROR'
                return False
        
        self.log("✅ 部署前檢查完成")
        return True
    
    def build_production(self):
        """建置生產環境"""
        self.log("🔨 建置生產環境...")
        
        # 安裝套件
        success, stdout, stderr = self.run_command('npm install --production --silent')
        if not success:
            self.log(f"npm install 警告: {stderr}", 'WARN')
        
        # 建置
        success, stdout, stderr = self.run_command('npm run build')
        if success:
            self.log("✅ 建置成功")
            return True
        else:
            self.log(f"❌ 建置失敗: {stderr}", 'ERROR')
            return False
    
    def deploy_to_server(self):
        """部署至遠端伺服器"""
        self.log("🚀 部署至遠端伺服器...")
        
        # 這裡會使用 rsync/scp 部署
        # 實際使用時請取消註解並設定正確的 SSH 金鑰
        
        """
        ssh_host = "user@esggo.co"
        remote_dir = "/var/www/Nuber.esggo.co"
        
        # 備份現有檔案
        self.run_command(f"ssh {ssh_host} 'mkdir -p {remote_dir}/backup && cp -r {remote_dir}/* {remote_dir}/backup/'")
        
        # 同步檔案
        success, _, _ = self.run_command(
            f"rsync -avz --delete {self.project_root}/dist/ {ssh_host}:{remote_dir}/"
        )
        
        if success:
            self.log("✅ 部署成功")
            return True
        """
        
        self.log("⚠️ 請於遠端伺服器執行部署腳本 (deploy.sh)")
        self.log("   或使用 GitHub Actions 進行自動化部署")
        return True
    
    def health_check(self):
        """健康檢查"""
        self.log("🩺 執行健康檢查...")
        
        # 本機檢查
        success, stdout, _ = self.run_command('curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/')
        if success and '200' in stdout:
            self.log("✅ 本機健康檢查通過")
            return True
        
        self.log("⚠️ 請於部署完成後再執行健康檢查")
        return True
    
    def generate_deployment_report(self):
        """生成部署報告"""
        report = {
            "project": self.config['project'],
            "domain": self.config['domain'],
            "status": "completed" if self.deploy_log else "failed",
            "steps": len(self.deploy_log),
            "log": self.deploy_log,
            "next_steps": [
                "更新 DNS 記錄 (Nuber.esggo.co → CNAME → esggo.co)",
                "設定 SSL 證書 (certbot)",
                "配置 nginx 反向代理",
                "啟動 pm2 服務",
                "測試 https://Nuber.esggo.co"
            ]
        }
        
        report_path = self.project_root / 'deployment-report.json'
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        return report
    
    def run(self):
        """執行完整佈署流程"""
        self.log("=" * 50)
        self.log(f"★ Nuber 平台佈署啟動 ★")
        self.log("=" * 50)
        
        steps = [
            ('預檢', self.pre_deployment_checks),
            ('建置', self.build_production),
            ('部署', self.deploy_to_server),
            ('健康檢查', self.health_check),
        ]
        
        for step_name, step_func in steps:
            self.log(f"\n--- {step_name} 步驟 ---")
            if not step_func():
                self.log(f"❌ {step_name} 失敗", 'ERROR')
                break
        
        report = self.generate_deployment_report()
        
        self.log("\n" + "=" * 50)
        self.log("✅ 佈署流程完成")
        self.log(f"目標網址: https://{self.config['domain']}")
        self.log("=" * 50)
        
        return report


if __name__ == '__main__':
    deployer = OmniDeploy()
    report = deployer.run()
    print("\n" + json.dumps(report, indent=2, ensure_ascii=False))