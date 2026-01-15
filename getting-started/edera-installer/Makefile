.PHONY: help deploy configure test verify clean

# Default target
help:
	@echo "Edera Manual Installation"
	@echo ""
	@echo "Available targets:"
	@echo "  deploy    - Install Edera on a target node (requires INSTALLER_IP)"
	@echo "  configure - Apply RuntimeClass and label nodes"
	@echo "  test      - Test the deployment by creating a test workload"
	@echo "  verify    - Verify the cluster and nodes are properly configured"
	@echo "  clean     - Clean up test resources"
	@echo ""
	@echo "Quick start:"
	@echo "  1. Save your GAR key as key.json"
	@echo "  2. INSTALLER_IP=<node-ip> make deploy"
	@echo "  3. make configure"
	@echo "  4. make test"

# Check that key.json exists
check-key:
	@if [ ! -f key.json ]; then \
		echo "Error: key.json not found!"; \
		echo "Please save your Google Artifact Registry key as key.json"; \
		exit 1; \
	fi

# Deploy Edera to a node
deploy: check-key
	@if [ -z "$(INSTALLER_IP)" ]; then \
		echo "Error: INSTALLER_IP is not set"; \
		echo "Usage: INSTALLER_IP=<node-ip> make deploy"; \
		exit 1; \
	fi
	@echo "Installing Edera on $(INSTALLER_IP)..."
	./scripts/install.sh
	@echo ""
	@echo "Installation complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  make configure  # Apply RuntimeClass and label nodes"
	@echo "  make test       # Test the deployment"

# Configure kubectl with RuntimeClass
configure:
	@echo "Applying Edera RuntimeClass..."
	kubectl apply -f https://public.edera.dev/kubernetes/runtime-class.yaml
	@echo ""
	@echo "RuntimeClass applied. Label your nodes with:"
	@echo "  kubectl label nodes <node-name> runtime=edera"
	@echo ""
	@echo "Or label all nodes:"
	@echo "  kubectl label nodes --all runtime=edera"

# Test the deployment
test:
	@echo "Testing Edera deployment..."
	@echo ""
	@echo "Node status:"
	kubectl get nodes -o wide
	@echo ""
	@echo "Node labels (checking for runtime=edera):"
	kubectl get nodes --show-labels | grep runtime=edera || echo "No nodes with runtime=edera label found"
	@echo ""
	@echo "RuntimeClass status:"
	kubectl get runtimeclass edera -o wide || echo "RuntimeClass not found"
	@echo ""
	@echo "Deploying test workload..."
	kubectl apply -f kubernetes/test-workload.yaml
	@echo ""
	@echo "Waiting for test pod to be ready..."
	kubectl wait --for=condition=ready pod/edera-test-pod -n edera-test --timeout=300s
	@echo ""
	@echo "Test pod is running!"
	@echo ""
	@echo "Test results:"
	kubectl get pods -n edera-test -o wide
	@echo ""
	@echo "Verifying pod is using Edera runtime:"
	@kubectl get pod edera-test-pod -n edera-test -o jsonpath="{.spec.runtimeClassName}"
	@echo ""
	@echo ""
	@echo "Success! Your node is running with Edera protection."

# Verify the deployment
verify:
	@echo "Verifying Edera installation..."
	@echo ""
	@echo "Cluster nodes:"
	kubectl get nodes
	@echo ""
	@echo "Edera RuntimeClass:"
	kubectl get runtimeclass edera
	@echo ""
	@echo "Test workload:"
	kubectl get pods -n edera-test

# Clean up test resources
clean:
	@echo "Cleaning up test resources..."
	kubectl delete -f kubernetes/test-workload.yaml --ignore-not-found=true
	@echo "Test resources cleaned up"
