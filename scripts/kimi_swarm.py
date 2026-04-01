#!/usr/bin/env python3
"""
Kimi Swarm - Multi-Agent System with Kimi Integration
This script creates a simple agent swarm that can utilize Kimi as one of the agents.
"""

import subprocess
import asyncio
import sys
from typing import Dict, List, Optional


class KimiAgent:
    """Agent that uses Kimi model through Ollama"""
    
    def __init__(self, model_name: str = "kimi-k2.5:cloud"):
        self.model_name = model_name
    
    async def process(self, prompt: str) -> str:
        """Process a prompt using Kimi"""
        try:
            # Run the Kimi model through Ollama
            proc = await asyncio.create_subprocess_exec(
                "ollama", "run", self.model_name,
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            stdout, stderr = await proc.communicate(input=prompt.encode())
            
            if proc.returncode == 0:
                return stdout.decode().strip()
            else:
                return f"Kimi Error: {stderr.decode()}"
        except asyncio.TimeoutError:
            return "Kimi Error: Request timed out"
        except Exception as e:
            return f"Kimi Error: {str(e)}"


class QwenAgent:
    """Agent that uses Qwen model through Ollama"""
    
    def __init__(self, model_name: str = "qwen2.5:0.5b"):
        self.model_name = model_name
    
    async def process(self, prompt: str) -> str:
        """Process a prompt using Qwen"""
        try:
            proc = await asyncio.create_subprocess_exec(
                "ollama", "run", self.model_name,
                stdin=asyncio.subprocess.PIPE,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            stdout, stderr = await proc.communicate(input=prompt.encode())
            
            if proc.returncode == 0:
                return stdout.decode().strip()
            else:
                return f"Qwen Error: {stderr.decode()}"
        except asyncio.TimeoutError:
            return "Qwen Error: Request timed out"
        except Exception as e:
            return f"Qwen Error: {str(e)}"


class SwarmCoordinator:
    """Coordinates multiple agents in a swarm"""
    
    def __init__(self):
        self.agents = {
            "kimi": KimiAgent(),
            "qwen": QwenAgent()
        }
    
    async def run_swarm(self, prompt: str, agents: List[str] = ["kimi", "qwen"]) -> Dict[str, str]:
        """Run a prompt across multiple agents"""
        tasks = []
        for agent_name in agents:
            if agent_name in self.agents:
                task = asyncio.create_task(
                    self.agents[agent_name].process(prompt)
                )
                tasks.append((agent_name, task))
        
        results = {}
        for agent_name, task in tasks:
            results[agent_name] = await task
        
        return results
    
    async def run_specialized_swarm(self, prompt: str) -> Dict[str, str]:
        """Run a specialized swarm where each agent handles different aspects"""
        # Determine which agent is best for which task
        kimi_prompt = f"As Kimi, analyze this: {prompt}"
        qwen_prompt = f"As Qwen, provide a technical perspective on: {prompt}"
        
        kimi_task = asyncio.create_task(self.agents["kimi"].process(kimi_prompt))
        qwen_task = asyncio.create_task(self.agents["qwen"].process(qwen_prompt))
        
        results = {
            "kimi": await kimi_task,
            "qwen": await qwen_task
        }
        
        # Combine results
        combined_prompt = f"""
        Kimi's analysis: {results['kimi']}
        
        Qwen's perspective: {results['qwen']}
        
        Provide a synthesized response combining both perspectives: {prompt}
        """
        
        # Use Kimi to synthesize the response as it might be better for this task
        results["synthesis"] = await self.agents["kimi"].process(combined_prompt)
        
        return results


def main():
    if len(sys.argv) < 2:
        print("Usage: python kimi_swarm.py \"Your prompt here\" [swarm_type]")
        print("  swarm_type: 'simple' (default) or 'specialized'")
        sys.exit(1)
    
    prompt = " ".join(sys.argv[1:2])  # Get the prompt
    swarm_type = sys.argv[2] if len(sys.argv) > 2 else "simple"  # Get the swarm type
    
    async def run():
        coordinator = SwarmCoordinator()
        
        if swarm_type == "specialized":
            results = await coordinator.run_specialized_swarm(prompt)
        else:
            results = await coordinator.run_swarm(prompt)
        
        print("=== KIMI SWARM RESULTS ===")
        for agent, response in results.items():
            print(f"\n--- {agent.upper()} RESPONSE ---")
            print(response)
    
    asyncio.run(run())


if __name__ == "__main__":
    main()