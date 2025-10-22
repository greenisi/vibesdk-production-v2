import { SandboxSdkClient } from "./sandboxSdkClient";
import { RemoteSandboxServiceClient } from "./remoteSandboxService";
import { BaseSandboxService } from "./BaseSandboxService";

export function getSandboxService(sessionId: string, agentId: string, env: Env): BaseSandboxService {
    if (env.SANDBOX_SERVICE_TYPE == 'runner') {
        console.log("[getSandboxService] Using runner service for sandboxing");
        // Initialize RemoteSandboxServiceClient if not already initialized
        if (!RemoteSandboxServiceClient.isInitialized()) {
            RemoteSandboxServiceClient.init(env.SANDBOX_SERVICE_URL, env.SANDBOX_SERVICE_API_KEY);
        }
        return new RemoteSandboxServiceClient(sessionId);
    }
    console.log("[getSandboxService] Using sandboxsdk service for sandboxing");
    return new SandboxSdkClient(sessionId, agentId, env);
}