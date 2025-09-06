// UI Components
export { Container, type ContainerProps } from './Container';
export { GradientText, type GradientTextProps } from './GradientText';
export { FantasyHeading, type FantasyHeadingProps } from './FantasyHeading';

// Layout Components
export { default as Layout } from './Layout';

// Re-export all components for easy access
import Container from './Container';
import GradientText from './GradientText';  
import FantasyHeading from './FantasyHeading';
import Layout from './Layout';

export const UIComponents = {
  Container,
  GradientText,
  FantasyHeading,
  Layout,
};

export default UIComponents;
